#! /bin/sh -e
# Write latest report files to production server.

FILES="
bot.sh
botlist.txt
html.sh
nobot.sh
parseday.sh
report.sh
"

SRC="./{"
DELIM=""
for f in $FILES; do
	SRC="${SRC}${DELIM}${f}"
	DELIM=","
done
SRC=${SRC}}

rsync -avz "$SRC" www:wwwreport
