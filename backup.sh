#!/bin/sh
prune=0
keep=1
date=`date "+%F_%H-%M"`
help="backup.sh [-n name] [-p] [-c count]\n\n-n\tSpecify the name of the archives\n-p\tEnable pruning\n-c\tNumber of archives to keep (default: 1)\n"

while getopts ":hn:pc:" opt; do
	case $opt in
	  h)
	    printf "$help"
	    exit 0;;
	  n)
	    name="$OPTARG_$date";;
	  p)
	    prune=1;;
	  c)
	    keep=$OPTARG;;
	  \?)
	    echo "Invalid option: -$OPTARG" >&2
	    printf "$help"
	    exit 1;;
	  :)
	    echo "Option -$OPTARG requires an argument." >&2
	    printf "$help"
	    exit 1;;
	esac
done

echo "Starting $name tarsnap backup..."

if /usr/local/bin/tarsnap --quiet -cf "$name"
then
	echo "Completed $name tarsnap backup."
else
	echo "Failed $name tarsnap backup."
	exit 1
fi

if [ $prune ]
then
	list=`/usr/local/bin/tarsnap --quiet --list-archives | grep $name | sort`
	wc=`echo "$list" | wc -l`
	if [ $wc -gt $count ]
	then
		delete=`expr $wc - $keep`
	 	list=`echo "$list" | head -n $delete | awk '{print "-f " $0}'`

		echo "Beginning prune of $name tarsnap backup..."

		if /usr/local/bin/tarsnap --quiet -d $list
		then
			echo "Successfully pruned $delete $name tarsnap backup."
		else
			echo "Failed prune of $name tarsnap backup."
			exit 1
		fi
	fi
fi

if /usr/local/bin/tarsnap --print-stats --humanize-numbers
then
	exit 0
else
	exit 1
fi
