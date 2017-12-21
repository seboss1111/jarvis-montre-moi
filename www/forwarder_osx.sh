#!/bin/bash

touch tmpBuffer
touch tmpBuffer.log
echo "" > tmpBuffer
echo "" > tmpBuffer.log
tmpVar=""
p="p"
i=1
nbLines=0
serverIsRunning=""

while true; do
	tmpVar="$(sed -n "$i$p" tmpBuffer)"
	if [ ! -z "$tmpVar" ]; then
		echo $tmpVar
		echo "$i => $tmpVar" >> tmpBuffer.log
	fi

	nbLines="$(grep -w '' -c tmpBuffer)"
	if [ $i -le $nbLines  ]; then
		echo "Line : $i / $nbLines" >> tmpBuffer.log
		i=$((i+1))
	fi

	sleep 0.5 &> /dev/null
done
