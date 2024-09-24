#!/bin/bash
FILENAME="iops.txt"

cleanup() {
        rm "$FILENAME"
}

trap 'cleanup' SIGINT

iostat -y -p $1 1 | grep --color=never --line-buffered -oP "nvme\dn\d\s+\K\d+" | tee "$FILENAME"
