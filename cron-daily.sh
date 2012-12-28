#!/bin/bash
input_folder=/vol/storage/logs/cron/
output_folder=/vol/storage/malta-output/cron
web_pattern=ISALOG_$(date +%Y%m%d)_WEB.*
fws_pattern=ISALOG_$(date +%Y%m%d)_FWS.*
parser=/home/sergioo/workspace/malta/parse-logs.pl

echo "Running with params: "
echo "Logs folder: $input_folder"
echo "Output Folder: $output_folder"
echo "Web files pattern: $web_pattern"
echo "Firewall files pattern: $fws_pattern"

perl $parser -i $input_folder -o $output_folder -w $web_pattern -f $fws_pattern
