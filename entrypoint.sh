#!/bin/bash

cd "$installdir"

# command line arguments
verb='help'
extra=''

# actually parse arguments
i=0
for arg in $@; do
	let i++
	[ $i -eq 1 ] && verb="$arg" || extra="$extra $arg"
done
[ -n "$extra" ] && extra="`echo "$extra" | cut -c 2-`"

case "$verb" in
	reload)
		[ "$extra" = '-f' ] && rm -f data/cal.ics data/parsed data/sha1
		./parse.sh
		;;
	get)
		[ -z "$extra" ] && extra="today"
		./forday.sh "`date -d "$extra" +"%Y/%m/%d"`"
		;;
	*)
		[ ! "$extra" = "help" ] && echo "Unrecognized verb: '$verb'"
		echo "Usage: edt <verb> [arg]"
		echo "where verb is one of 'reload', 'get'"
		;;
esac
