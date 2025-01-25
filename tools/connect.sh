#!/bin/bash

IP="10.0.0.4"
PORT=4420

sudo modprobe nvme-tcp
sudo nvme discover --transport tcp --traddr $IP --trsvcid $PORT
sudo nvme connect -t tcp -n nqn.2024-09.io.spdk:cnode0 -a $IP -s $PORT
