#:/bin/bash
cd "$installdir"

dl=''

if [ ! -f data/cal.ics ]; then
	# if we don't have a calendar, we should probably get one at some point
	dl='true'
elif [ `stat -c %Y data/cal.ics` -lt `date --date='yesterday' +%s` ]; then
	# if the calendar is too old, download a new one
	dl='true'
fi

if [ -n "$dl" ]; then
	# download the calendar
	echo "Downloading calendar..."
	if curl `cat data/url` > data/cal.tmp; then
		cat data/cal.tmp | egrep -v "^LAST-MODIFIED:" | egrep -v "^SEQUENCE:" | egrep -v "^DTSTAMP:" > data/cal.ics
	else
		echo "Failed to download the calendar, reusing old version for now"
	fi
	rm data/cal.tmp
else
	echo "The calendar is already up to date"
fi
