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
	curl `cat data/url` | egrep -v "^LAST-MODIFIED:" | egrep -v "^SEQUENCE:" | egrep -v "^DTSTAMP:" > data/cal.ics
else
	echo "The calendar is already up to date"
fi
