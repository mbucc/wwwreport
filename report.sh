#! /bin/sh -e
# Generate web stats report.

YESTERDAY=$(date -d "-1 day" +"%d/%b/%Y")

# Cache access log entries from yesterday to temp file.
F=$(mktemp)
for f in $(find /var/log/nginx -name "markbucciarelli.log*" -mtime -3 | xargs ls -tr) ; do 
	if echo $f | grep gz$ >/dev/null ; then
		gunzip -c $f   # >> $F
	else
		cat $f # >> $F
	fi
done  | grep "\[$YESTERDAY" > $F


# Print report to stdout.
printf "Generated on "
echo $(date)

TOTAL=$(cat $F | wc -l)

printf "\n\nStatus Codes (Total lines in access log = $TOTAL)\n--------------------------------------------------\n"
cat $F | cut -d '"' -f3 | cut -d ' ' -f2 | sort | uniq -c | sort -rn

printf "\n\nHTML Status Codes\n--------------------------------------------------\n"
cat $F | $HOME/bin/html.sh | cut -d '"' -f3 | cut -d ' ' -f2 | sort | uniq -c | sort -rn

printf "\n\n404's\n--------------------------------------------------\n"
cat $F | awk '($9 ~ /404/)' | awk '{print $7}' | sort | uniq -c | sort -rn

printf "\n\nPopular Pages (filtering out bots)\n--------------------------------------------------\n"
cat $F | $HOME/bin/nobot.sh | $HOME/bin/html.sh |awk -F\" '{print $2}'| awk '{print $2}' | sort | uniq -c | sort -rn

printf "\n\nReferers (not including markbucciarelli.com)\n--------------------------------------------------\n"
cat $F | awk -F\" '{print $4}' |egrep -iv '^ *http://(www\.)?markbucciarelli.com'| sort | uniq -c | sort -rn

printf "\n\nBots (all resources)\n--------------------------------------------------\n"
cat $F | $HOME/bin/bot.sh |awk -F\" '{print $6}'| sort | uniq -c | sort -r


printf "\n\ntop domains requesting HTML pages (no bots)\n--------------------------------------------------\n"
set +e
cat $F \
  | $HOME/bin/nobot.sh \
  | $HOME/bin/html.sh \
  | awk '{print $1}'  \
  | while read ip ; do printf "%s  " $ip; host $ip; done \
  | awk '$0 ~ /not found:/ {a[$1] = a[$1] + 1; next} {n=split($6,b,"."); i=b[n-2]"."b[n-1]; a[i]=a[i]+1; if (i in ips && !(ip in seen)) {ips[i]=ips[i] "," $1} else {ips[i]=$1};seen[ip]=1;} END {for (i in a) print a[i], i, ips[i]}' \
  | sort -rn \
  | column -t

printf "\n\nChange Log\n"
printf "2016-09-17\n"
printf "  * add Stratagems Kumo, roboto and AhrefsBot to bot list\n"
printf "2016-09-14\n"
printf "  * show list of IP's in top domain section"
printf "2016-08-31\n"
printf "  * added spbot, AppleBot, Google Favicon, PaperLiBot, Veoozbot and Yahoo! Slurp to botlist.\n"
printf "2016-08-24\n"
printf "  * added curl and NetShelter to bot list.\n"
printf "  * skip HEAD requests when reporting page views\n"
printf "  * include home page when reporting on HTML views\n"
printf "2016-08-23\n"
printf "  * added SeznamBot and DuckDuckGo-Favicons-Bot to bot list.\n"
printf "  * filter out bots when listing top requesting domains\n"

rm -f $F
