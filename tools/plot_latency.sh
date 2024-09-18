#!/bin/bash
WATCH_HEADER=2
COLS=$(tput cols)
LINES=$(tput lines)
LINES=$((LINES-WATCH_HEADER))

gnuplot -e "set terminal dumb $COLS,$LINES; set xlabel \"Seconds\"; set ylabel \"(ms)\"; plot \"latency.txt\" with lines notitle"
