#!/bin/sh
folder=`dirname $0`
type=`echo ${folder} | rev | cut -f 1 -d '/' | rev`
date=`date "+%Y-%m-%d"`

echo "Starting $type tarsnap backup..."

/usr/local/bin/tarsnap --quiet -T ${folder}/include.txt -X ${folder}/exclude.txt -cf "${type}_${date}"

if [ $? -eq 0 ]
then
	echo "Completed $type tarsnap backup."
else
	echo "Failed $type tarsnap backup."
fi

if [ -n $1 ]
then
	keep=$1
	list=`/usr/local/bin/tarsnap --quiet --list-archives | grep $type | sort`
	wc=`echo "$list" | wc -l`
	if [ $wc -gt $keep ]
	then
		delete=`expr $wc - $keep`
	 	list=`echo "$list" | head -n $delete | awk '{print "-f " $0}'`

		echo "Beginning prune of $type tarsnap backup..."

		/usr/local/bin/tarsnap --quiet -d $list

		if [ $? -eq 0 ]
		then
			echo "Completed prune of $type tarsnap backup."
		else
			echo "Failed prune of $type tarsnap backup."
		fi
	fi
fi

/usr/local/bin/tarsnap --quiet --print-stats --humanize-numbers
