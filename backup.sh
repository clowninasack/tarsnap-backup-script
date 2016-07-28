#!/bin/sh
prune=$false
keep=1
stats=$true
tarsnap_args="--quiet"
date=`date "+%F_%H-%M"`
name="backup"
help="backup.sh [-h] [-n name] [-p] [-c count] [-i include] [-x exclude] [-s] [files | directories]\n\n-h\tShow this text\n-n\tSpecify the name of the archives (default: "backup")\n-p\tEnable pruning\n-c\tNumber of archives to keep (default: 1)\n-i\tInclude file\n-x\tExclude file\n-s\tDo not print statistics\n"

while getopts ":hn:pc:i:x:s" opt; do
	case $opt in
	  h)
	    printf "$help"
	    exit 0
	    ;;
	  n)
	    name="${OPTARG}"
	    ;;
	  p)
	    prune=$true
	    ;;
	  c)
	    if [ $OPTARG -gt 1 ] 2>/dev/null
	    then
	    	keep=$OPTARG
	    else
	    	echo "Count must be greater than 1."
	    	exit 1
	    fi
	    ;;
	  i)
	    tarsnap_args="$tarsnap_args -T $OPTARG"
	    ;;
	  x)
	    tarsnap_args="$tarsnap_args -X $OPTARG"
	    ;;
	  s)
	    stats=$false
	    ;;
	  \?)
	    echo "Invalid option: -$OPTARG" >&2
	    printf "$help"
	    exit 1
	    ;;
	  :)
	    echo "Option -$OPTARG requires an argument." >&2
	    printf "$help"
	    exit 1
	    ;;
	esac
done

shift $((OPTIND-1))

echo "Starting $name tarsnap backup..."

if /usr/local/bin/tarsnap $tarsnap_args -cf "${name}_${date}" $*
then
	echo "Successfully completed $name tarsnap backup."
else
	echo "Failed $name tarsnap backup."
	exit 1
fi

if [ $prune ]
then
	list=`/usr/local/bin/tarsnap --quiet --list-archives | grep $name | sort`
	archives=`echo "$list" | wc -l | tr -d " "`
	if [ $archives -gt $keep ]
	then
		delete=`expr $archives - $keep`
	 	list=`echo "$list" | head -n $delete | awk '{print "-f " $0}'`

		echo "Beginning prune of $delete $name tarsnap backups..."

		if /usr/local/bin/tarsnap --quiet -d $list
		then
			echo "Successfully pruned $delete $name tarsnap backups."
		else
			echo "Failed prune of $name tarsnap backups."
			exit 1
		fi
	else
		echo "Pruning not required."
	fi
fi

if [ $stats ]
then
	echo "Tarsnap stats:"
	/usr/local/bin/tarsnap --print-stats --humanize-numbers
fi

exit 0
