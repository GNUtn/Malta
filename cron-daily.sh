#!/bin/bash
input_folder=/vol/storage/logs/cron/
output_folder=/vol/storage/malta-output/cron
web_pattern=ISALOG_$(date +%Y%m%d)_WEB.*
fws_pattern=ISALOG_$(date +%Y%m%d)_FWS.*
web_parser=/home/sergioo/malta/parse-logs-web.pl
fw_parser=/home/sergioo/malta/parse-logs-firewall.pl
dates=20130116
updater=/home/sergioo/malta/update-globals.pl

echo "Running with params: "
echo "Logs folder: $input_folder"
echo "Output Folder: $output_folder"
echo "Web files pattern: $web_pattern"
echo "Firewall files pattern: $fws_pattern"

perl $web_parser -i $input_folder -o $output_folder -w $web_pattern -d $dates
perl $fw_parser -i $input_folder -o $output_folder -f $fws_pattern -d $dates
perl $updater  -i $input_folder -o $output_folder -d $dates
