#!/bin/bash
NET=${1:-192.168.0.1/24}
OUT=${2:-/tmp/network.gmap}

# Source: https://h4knet.medium.com/pretty-print-nmap-grepable-gnmap-files-56ffd6ca9e20
nmapcat() { grep -hv "Status: Down\|Status: Up" $@ | grep "^#\|/open/" |sed s/'\t'/'\n\t'/g |sed s/'\/, '/'\n\t\t'/g |sed s/'Ports: '/'Ports:\n\t\t'/g |grep -v "/closed/\|filtered/" |sed "/Host:/ s=(\(.*\))=($(tput setaf 4)\1$(tput sgr0))=" |sed "s/Host:/$(tput setaf 1)&$(tput sgr0)/g" |sed "/\t\t/ s=\(\t\t[0-9]*\)=$(tput setaf 2)\1$(tput sgr0)=" |awk -F '/' '{OFS=FS; if (NF<2) {print;next} else $7="\033[01;33m"$7"\033[00m";print}' |sed "/OS:/ s= .*=$(tput setaf 5)&$(tput sgr0)=" |sed "s/^#.*/$(tput setaf 6)&$(tput sgr0)/"; }

nmap -sT ${NET} -oG ${OUT}
nmapcat ${OUT}
