#!/bin/sh
prune=0
keep=1
tarsnap_args="--quiet"
date=`date "+%F_%H-%M"`
name="backup"
help="backup.sh [-h] [-n name] [-p] [-c count] [-i include] [-x exclude] [files | directories]\n\n-h\tShow this text\n-n\tSpecify the name of the archives (default: "backup")\n-p\tEnable pruning\n-c\tNumber of archives to keep (default: 1)\n-i\tInclude file\n-x\tExclude file\n"

while getopts ":hn:pc:i:x:" opt; do
	case $opt in
	  h)
	    printf "$help"
	    exit 0
	    ;;
	  n)
	    name="${OPTARG}"
	    ;;
	  p)
	    prune=1
	    ;;
	  c)
	    if [ $OPTARG -gt 1 ]
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
	echo "Completed $name tarsnap backup."
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
else
	echo "prune off"
fi

if /usr/local/bin/tarsnap --print-stats --humanize-numbers
then
	exit 0
else
	exit 1
fi
