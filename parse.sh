#!/bin/bash

# constants and functions
fmtdate() {
	echo "`echo $1 | cut -c 1-4`/`echo $1 | cut -c 5-6`/`echo $1 | cut -c 7-8` `echo $1 | cut -c 10-11`:`echo $1 | cut -c 12-13` UTC"
}
dateoutfmt="%Y/%m/%d %H:%M:%S"

cd "$installdir"

./get.sh

redo=''

if [ ! -f data/parsed ] || [ ! -f data/sha1 ]; then
	# we don't have a parsed value at all
	redo='true'
elif [ data/parsed -ot data/cal.ics ]; then
	# our parsed value is older than the calendar
	# hash it and compare it to the old hash
	sha1=`sha1sum data/cal.ics`
	if [ "`cat data/sha1`" != "$sha1" ]; then
		redo='true'
	fi
fi

if [ -n "$redo" ]; then
	echo "Parsing calendar..."
	
	# nuke anything we could have had
	rm -f data/parsed
	touch data/parsed
	rm -f data/sha1
	sha1sum data/cal.ics > data/sha1
	
	# init
	class=''
	room=''
	stime=''
	etime=''

	# read all lines of the file
	IFS=$'\r\n'
	for line in `cat data/cal.ics`; do
		fragment="`echo $line | cut -d : -f 2-`"
		command="`echo $line | cut -d : -f 1`"
		# echo "$command : $fragment"
		case $command in
			BEGIN)
				# reset everything
				if [ "$fragment" = "VEVENT" ]; then
					class=''
					room=''
					stime=''
					etime=''
				fi
				;;
			LOCATION)
				# set location
				room="$fragment"
				;;
			SUMMARY)
				# set class
				class="$fragment"
				;;
			DTSTART)
				# set start time
				dt="`fmtdate "$fragment"`"
				stime="`date -d $dt +"$dateoutfmt"`"
				;;
			DTEND)
				# set end time
				dt="`fmtdate "$fragment"`"
				etime="`date -d $dt +"$dateoutfmt"`"
				;;
			END)
				# append the event to the list
				if [ "$fragment" = "VEVENT" ]; then
					echo "$stime|$etime|$class|$room" >> data/parsed
				fi
				;;
			*)
				# do nothing
				;;
		esac
	done
	sort data/parsed > data/tmp
	mv data/tmp data/parsed
else
	echo "This version of the calendar doesn't have to be parsed"
fi
