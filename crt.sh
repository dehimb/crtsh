#!/bin/bash
#
#author dehimb

RESULTS_PATH=`pwd`/crtsh
mkdir -p $RESULTS_PATH 
rm -rf $RESULTS_PATH/*
OUTPUT_FILENAME=domains_crt.txt
total=1
count=1

function request_subdomains() {
	echo -en "`echo $(($count*100/$total))`% -> $1\n"
	curl -s https://crt.sh/?q=%.$1\&output=json | jq -r '.[].name_value' 2>/dev/null | sed 's/\*\.//g' | sort -u -o $RESULTS_PATH/domains_$1.txt
	cat $RESULTS_PATH/domains_$1.txt | httprobe -c 50 > $RESULTS_PATH/responsive_$1.txt
}

if [ -f "$1" ]; then
	total=`wc -l $1 | awk '{print $1}'`
	for target in `cat $1`; do
		request_subdomains $target
		count=$((count+1))
	done
else
	request_subdomains $1
fi
cat $RESULTS_PATH/responsive_* | sed -E 's/http\:\/\/|https\:\/\///g' | sort -u -o $RESULTS_PATH/$OUTPUT_FILENAME
cat $RESULTS_PATH/domains_crt.txt >> `pwd`/$OUTPUT_FILENAME
sort -u -o `pwd`/$OUTPUT_FILENAME `pwd`/$OUTPUT_FILENAME
