#!/bin/bash
WATCH_HEADER=2
COLS=$(tput cols)
LINES=$(tput lines)
LINES=$((LINES-WATCH_HEADER))

gnuplot -e "set terminal dumb $COLS,$LINES; set xlabel \"Seconds\"; set yrange [20000:80000]; set ylabel \"IOPS\"; plot \"iops.txt\" with lines notitle"
