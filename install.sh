#!/bin/bash
# This file will be automatically sourced at the installation of your plugin
# Use only if you need to perform changes on the user system such as installing software
jv_debug "Downloading websocketd"
jv_pg_mm_www_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"/www
if [[ "$platform" == "linux" ]]; then
	# Start in new terminal to avoid blocking Jarvis              
	wget "https://github.com/joewalnes/websocketd/releases/download/v0.2.12/websocketd-0.2.12-linux_arm.zip"
	unzip -j "websocketd-0.2.12-linux_arm.zip" "websocketd" -d $jv_pg_mm_www_path
	rm websocketd-0.2.12-linux_arm.zip
elif [[ "$platform" == "osx" ]]; then
    wget "https://github.com/joewalnes/websocketd/releases/download/v0.2.12/websocketd-0.2.12-darwin_amd64.zip"
    unzip -j "websocketd-0.2.12-darwin_amd64.zip" "websocketd" -d $jv_pg_mm_www_path
	rm websocketd-0.2.12-darwin_amd64.zip
fi