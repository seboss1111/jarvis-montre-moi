#!/bin/bash


# Face to use 
# The Gif file for each state must be put under 
# 	./www/img/faces/<bot_face>/<status>/<status>.gif
# ex: ./www/img/faces/fluorescent/neutral/neutral.gif
# Supported states : neutral, speaking, thinking
# Leave empty to the default robot face
jv_pg_mm_bot_face=""

# Use Qwant search engine instead of Google
jv_pg_mm_use_qwant=false

# Port to use for the WebSocket Server
jv_pg_mm_server_port=8686

# For Linux / Raspberry Pi
if [[ "$platform" == "linux" ]]; then
	# Command to open prefered browser (Raspberry pi)
	# For Chromium you can add --kiosk --start-fullscreen for kiosk mode
	jv_pg_mm_browser_command="chromium-browser"

	# Delay in millisec for synchronization with 'speaking' animation
	jv_pg_mm_speak_delay=0

# For MAC
elif [[ "$platform" == "osx" ]]; then
	# Command to open the browser (Mac)
	jv_pg_mm_browser_command="open -a Safari"

	# Delay in millisec for synchronization with 'speaking' animation
	jv_pg_mm_speak_delay=1000
fi

# Global internal variables
jv_pg_mm_server_started=false
jv_pg_mm_not_exiting=true
jv_pg_mm_server_pid=""
jv_pg_mm_forwarder_pid=""
