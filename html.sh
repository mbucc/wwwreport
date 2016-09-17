#! /bin/sh -e
# Pass through GET requests for / and html pages.

awk -F\" '$2 ~ /GET .*\.html/ {print} $2 ~ /GET \/ / {print}'
