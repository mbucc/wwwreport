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

rsync -avz $FILES www:wwwreport
