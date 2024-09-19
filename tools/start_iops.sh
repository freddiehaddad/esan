#!/bin/bash
rm iops.txt
iostat -y -p nvme1n1 1 | grep --color=never --line-buffered -oP "nvme\dn\d\s+\K\d+" | tee iops.txt
