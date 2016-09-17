#! /bin/sh -e
# Generate web usage report.

[ "x$1" = "x" ] && echo "usage: $(basename $0) <days_ago>" 1>&2 && exit 1

DT=$(date -d "-$1 day" +"%d/%b/%Y")

#
# Could optimize for far back reports by telling find to return less files, ala:
# 		-newermt 2010-10-07 ! -newermt 2014-10-08
#
MTIME=$((2 + $1))


for f in $(find /var/log/nginx -name "markbucciarelli.log*" -mtime -$MTIME | xargs ls -tr) ; do 
	if echo $f | grep gz$ >/dev/null ; then
		gunzip -c $f   # >> $F
	else
		cat $f # >> $F
	fi
done  | grep "\[$DT"
