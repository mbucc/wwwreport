#! /bin/sh -e
# Copy latest report files from production server.

rsync -avz www:wwwreport/ .
ssh www "crontab -l | grep wwwreport" > crontab.entry
