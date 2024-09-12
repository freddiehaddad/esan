#!/bin/bash
gnuplot -e 'set terminal dumb 140,24; set xlabel "Seconds"; set ylabel "(ms)"; plot "latency.txt" with lines notitle'
