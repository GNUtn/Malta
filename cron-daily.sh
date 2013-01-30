#!/bin/bash
dates=$(date +%Y%m%d --date='-1 day')

input_folder=/mnt/tmglog/
output_folder=/vol/storage/malta-output/
#web_pattern=ISALOG_20130122_WEB.*
web_pattern=ISALOG_$(date +%Y%m%d --date='-1 day')_WEB.*

fws_pattern=ISALOG_$(date +%Y%m%d --date='-1 day')_FWS.*
#fws_pattern=ISALOG_20130122_FWS.*
web_parser=/home/nataliam/malta/parse-logs-web.pl
fw_parser=/home/nataliam/malta/parse-logs-firewall.pl
#dates=20130122
updater=/home/nataliam/malta/update-globals.pl

echo "Running with params: "
echo "Logs folder: $input_folder"
echo "Output Folder: $output_folder"
echo "Web files pattern: $web_pattern"
echo "Firewall files pattern: $fws_pattern"

perl $web_parser -i $input_folder -o $output_folder -w $web_pattern -d $dates
perl $fw_parser -i $input_folder -o $output_folder -f $fws_pattern -d $$
perl $updater  -i $input_folder -o $output_folder -d $dates

cp -r /vol/storage/malta-output /vol/storage/malta-output.$date

