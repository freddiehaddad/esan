#!/bin/bash
FILENAME="latency.txt"

cleanup() {
        rm "$FILENAME"
}

trap 'cleanup' SIGINT

iostat –y -x -p $1 1 | grep --color=never --line-buffered -P "nvme\dn\d" | stdbuf --output=L awk '{ print $12 }' | tee "$FILENAME"
