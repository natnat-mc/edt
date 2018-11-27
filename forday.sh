#!/bin/bash
cd "$installdir"

./parse.sh

IFS=$'\n'
for line in `cat data/parsed`; do
	sdate=`echo "$line" | cut -d '|' -f 1`
	sday=`echo "$sdate" | cut -d ' ' -f 1`
	if [ "$sday" = "$1" ]; then
		shour=`echo "$sdate" | cut -d ' ' -f 2`
		ehour=`echo "$line" | cut -d '|' -f 2 | cut -d ' ' -f 2`
		class=`echo "$line" | cut -d '|' -f 3`
		room=`echo "$line" | cut -d '|' -f 4`
		printf 'Le \e[32m'"$sday"'\e[0m, '
		printf '\e[32;1m'"$shour"'\e[0m-\e[32;1m'"$ehour"'\e[0m: '
		printf 'cours de \e[32m'"$class"'\e[0m '
		printf 'en salle \e[33m'"$room"'\e[0m\n'
	fi
done
