#!/bin/bash
# Here you can define translations to be used in the plugin functions file
# the below code is an sample to be reused:
# 1) uncomment to function below
# 2) replace XXX by your plugin name (short)
# 3) remove and add your own translations
# 4) you can the arguments $2, $3 passed to this function
# 5) in your plugin functions.sh file, use it like this:
#      say "$(pv_myplugin_lang the_answer_is "oui")"
#      => Jarvis: La réponse est oui

pg_show_me_lang () {
   case "$1" in
   	mm_preparing_phrase) echo "One moment, I'm getting ready...";;
	mm_here_i_am) echo "Here I am";;

    mm_order_regex) echo ".*show me (.*)";;
	mm_not_understood) echo "I did not understand what to show.";;
	mm_not_found) echo "Sorry, I did not find any pictures.";;
	mm_thinking_phrase) echo "I'm looking for available images...";;
	mm_textual_response) echo "Here's '$2'...";;
	mm_not_ready) echo "I can't right now...";;

   esac
} 
