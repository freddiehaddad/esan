#!/bin/bash
gnuplot -e 'set terminal dumb 140,40; set xlabel "Seconds"; set ylabel "IOPS"; plot "iops.txt" with lines notitle'
