#!/bin/bash
rm latency.txt
iostat –y -x -p nvme1n1 1 | grep --color=never --line-buffered -P "nvme\dn\d" | stdbuf --output=L awk '{ print $12 }' | tee latency.txt
