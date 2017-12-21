#!/bin/bash
# Here you can create functions which will be available from the commands file
# You can also use here user variables defined in your config file
# To avoid conflicts, name your function like this
# pg_XX_myfunction () { }
# pg for PluGin
# XX is a short code for your plugin, ex: ww for Weather Wunderground
# You can use translations provided in the language folders functions.sh

# Internal variables
jv_pg_mm_www_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"/www
jv_pg_mm_buffer_file="$jv_pg_mm_www_path/tmpBuffer"
jv_pg_mm_lang="$(tr '[:upper:]' '[:lower:]' <<< ${language:0:2})" # en_GB => en => EN

jv_pg_mm_forwarder_down_check="0"
jv_pg_mm_forwarder_is_up=false
jv_pg_mm_g_img_regex="[\"]ou[\"]:[\"](http[^\"]*)[\"]"

jv_pg_mm_show_you()
{
    # Start thinking...
    reflexionPid=""
    say "$(pg_show_me_lang mm_preparing_phrase)" > /dev/tty & 
    reflexionPid="$!"

    jv_pg_mm_start_server
    jv_pg_mm_check_forwarder

    init_parameters="userName=$username&botName=$trigger&botFace=$jv_pg_mm_bot_face&speakDelay=$jv_pg_mm_speak_delay&useQwant=$jv_pg_mm_use_qwant"
	server_url="http://localhost:$jv_pg_mm_server_port/index.html?$init_parameters"
    #jv_debug "Starting Browser : $server_url"    
	if [[ "$platform" == "linux" ]]; then
    # Start in new terminal to avoid blocking Jarvis              
    lxterminal --geometry=1x1 -e $jv_pg_mm_browser_command "http://$jv_ip:$jv_pg_mm_server_port/index.html?$init_parameters" 
    elif [[ "$platform" == "osx" ]]; then
        $jv_pg_mm_browser_command "$server_url"
    fi

    wait "$reflexionPid"
    say "$(pg_show_me_lang mm_here_i_am)" > /dev/tty
}


jv_pg_mm_enqueue_event()
{
    #jv_debug "Enqueue event : $1 / $2 | started = $jv_pg_mm_server_started"

    #jv_debug "Current Forwarder = $jv_pg_mm_forwarder_pid"

    jv_pg_mm_check_forwarder

    #jv_debug "Forwarder after check = $jv_pg_mm_forwarder_is_up : $jv_pg_mm_forwarder_pid"

    if [ $jv_pg_mm_forwarder_is_up = true ] && [ $jv_pg_mm_not_exiting = true ]; then
        #jv_debug "OK : Forwarder is up at #$jv_pg_mm_forwarder_pid"

        if [[ "$platform" == "linux" ]]; then
            echo "{ \"status\" : \"$1\", \"detail\" : \"$2\" }" > /proc/$jv_pg_mm_forwarder_pid/fd/0 
        elif [[ "$platform" == "osx" ]]; then
            #jv_debug "Write ... "
            echo "{ \"status\" : \"$1\", \"detail\" : \"$2\" }" >> $jv_pg_mm_buffer_file
        fi
    fi
}

jv_pg_mm_show_me()
{
    reflexionPid=""
    if [[ "$jv_pg_mm_server_started" = true ]]
    then
        local regex="$(pg_show_me_lang mm_order_regex)"
        if [[ $order =~ $regex ]]
        then
            #jv_debug "OK : 1=${BASH_REMATCH[1]}"
            textToSearch=${BASH_REMATCH[1]}
            say "$(pg_show_me_lang mm_thinking_phrase)" &
            reflexionPid="$!"

			if [[ "$jv_pg_mm_use_qwant" = true ]]
    		then
            	imgUrl="$(jv_pg_mm_qwant_img_search "$textToSearch")"
			else
            imgUrl="$(jv_pg_mm_google_img_search "$textToSearch")"
			fi

            wait "$reflexionPid"
            #jv_debug "ImgUrl : $imgUrl"
            if [[ ! -z "$imgUrl" ]]
            then
                jv_pg_mm_forwarder_pid="$(pgrep -n forwarder.sh)"
                jv_pg_mm_enqueue_event "show_image" "$imgUrl"
                say "$(pg_show_me_lang mm_textual_response "$textToSearch")"
            else
                # No image found
                say "$(pg_show_me_lang mm_not_found)"
            fi
        else
            # Invalid sentence format
            say "$(pg_show_me_lang mm_not_understood)"
        fi
    else
        #jv_debug "Show me called before show you !"
        say "$(pg_show_me_lang mm_not_ready)"
        jv_pg_mm_show_you
    fi
}

jv_pg_mm_qwant_img_search()
{
    # Prepare request 
    local request="https://api.qwant.com/api/search/images?"
    request+="count=1"
    request+="&q=$(uriencode "$1")"
    request+="&l=$jv_pg_mm_lang"
    request+="&s=2"
    #jv_debug "Request : $request"
    searchResut=$(curl -s "$request" -H 'Pragma: no-cache' -H 'Accept-Encoding: gzip, deflate, br' -H 'Accept-Language: fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7' -H 'Upgrade-Insecure-Requests: 1' -H 'User-Agent: Mozilla/5.0 (iPhone; CPU iPhone OS 9_1 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13B143 Safari/601.1' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8' -H 'Cache-Control: no-cache' -H 'Connection: keep-alive' --compressed)
    #jv_debug "Result : $searchResut"
    imgUrl=$(echo $searchResut | jq -r '.data.result.items[0].media')
    
    echo $imgUrl
}

jv_pg_mm_google_img_search()
{
    # Prepare request 
    local request="https://www.google.fr/search?"
    request+="safe=active"
    request+="&q=$(uriencode "$1")"
    request+="&hl=$jv_pg_mm_lang"
    request+="&tbm=isch"
    #jv_debug "Request : $request"
    searchResut=$(curl -s "$request" -H 'Pragma: no-cache' -H 'Accept-Encoding: gzip, deflate, br' -H 'Accept-Language: fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7' -H 'Upgrade-Insecure-Requests: 1' -H 'User-Agent: Mozilla/5.0 (iPhone; CPU iPhone OS 9_1 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13B143 Safari/601.1' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8' -H 'Cache-Control: no-cache' -H 'Connection: keep-alive' --compressed)
    #jv_debug "Result : $searchResut"
    imgUrl=""
    if [[ "$searchResut" =~ $jv_pg_mm_g_img_regex ]]
    then
        imgUrl=${BASH_REMATCH[1]}
    fi

    echo $imgUrl
}

jv_pg_mm_check_forwarder()
{
    if [[ "$platform" == "linux" ]]; then
		# Looks like the $jv_pg_mm_forwarder_pid is not kept 
    # Retreive the forwarder pid
    jv_pg_mm_forwarder_pid="$(pgrep -n forwarder.sh)"
    # Check if forwarder standard input is ready
    if [ ! -e /proc/$jv_pg_mm_forwarder_pid/fd/0 ]; then
        jv_pg_mm_forwarder_is_up=false
        #jv_debug "Forwarder input not found..."
        jv_pg_mm_forwarder_down_check=$[$jv_pg_mm_forwarder_down_check+1]
        if [ "$jv_pg_mm_forwarder_down_check" -gt "3" ]; then
            #jv_debug "Forwarder is down => restart ws server"
            jv_pg_mm_forwarder_down_check="0"
            jv_pg_mm_server_started=false
            jv_pg_mm_start_server
        fi
    else
        jv_pg_mm_forwarder_down_check="0"
        jv_pg_mm_forwarder_is_up=true
    fi
    elif [[ "$platform" == "osx" ]]; then
		jv_pg_mm_forwarder_pid="$(pgrep -n websocketd)"
        jv_pg_mm_forwarder_down_check="0"
        jv_pg_mm_forwarder_is_up=true
    fi
}

jv_pg_mm_start_server()
{
    # Retreive the server pid
    jv_pg_mm_server_pid="$(pgrep -n websocketd)"
    if [[ ! -z "$jv_pg_mm_server_pid" ]]
    then
        jv_pg_mm_server_started=false
        echo "Stoping old WS server $jv_pg_mm_server_pid"
        kill $jv_pg_mm_server_pid
    fi

    #jv_debug "Starting new Server on port '$jv_pg_mm_server_port'"
    #jv_debug "Www folder=$jv_pg_mm_www_path"

    cd $jv_pg_mm_www_path
    
    if [[ "$platform" == "linux" ]]; then
    # Start in new terminal to avoid blocking Jarvis                                   
    lxterminal --geometry=1x1 -e ./websocketd --staticdir=. --port=$jv_pg_mm_server_port ./forwarder.sh 
    elif [[ "$platform" == "osx" ]]; then
		# Open in terminal not working well undex OSX
        ./websocketd --staticdir=. --port=$jv_pg_mm_server_port ./forwarder_osx.sh &
    fi

    jv_pg_mm_server_started=true

    cd $jv_dir

    jv_pg_mm_server_pid="$(pgrep -n websocketd)"
}

uriencode() {
  s="${1//'%'/'%25'}"
  s="${s//' '/'%20'}"
  s="${s//'"'/'%22'}"
  s="${s//'#'/'%23'}"
  s="${s//'$'/'%24'}"
  s="${s//'&'/'%26'}"
  s="${s//'+'/'%2B'}"
  s="${s//','/'%2C'}"
  s="${s//'/'/'%2F'}"
  s="${s//':'/'%3A'}"
  s="${s//';'/'%3B'}"
  s="${s//'='/'%3D'}"
  s="${s//'?'/'%3F'}"
  s="${s//'@'/'%40'}"
  s="${s//'['/'%5B'}"
  s="${s//']'/'%5D'}"
  printf %s "$s"
}