#!/bin/bash

clk_tck=$(getconf CLK_TCK)

echo "PID||TTY||STAT||TIME||COMMAND"

for pid in $(ls -l /proc | awk '{print $9}' | grep -s "^[0-9]*[0-9]$"| sort -n );
do

	tty=$(ll 2>/dev/null /proc/$pid/fd/2 | awk '{print $11}' | cut -d'/' -f3,4)
	stat=$(cat 2>/dev/null /proc/$pid/stat | awk '{print $3}')
	utime=$(cat 2>/dev/null /proc/$pid/stat | awk '{print $14}')
	stime=$(cat  2>/dev/null /proc/$pid/stat | awk '{print $17}')
	cmd=$(cat 2>/dev/null /proc/$pid/status | head -1 | cut -d' ' -f1 |  awk '{print $2}')

	ttime=$((utime + stime))
	time=$((ttime / clk_tck))
	printf "%-8s | %-15s | %s\n" "$pid | $tty | $stat | $time | $cmd" | column -t  -s '|'
done
