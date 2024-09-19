#!/bin/bash

pushd /opt/spdk/

IP=$(ip address show dev eth0 | grep -oP "inet \K\d+.\d+.\d+.\d+") && echo $IP
PORT=4420
NQN="nqn.2024-09.io.spdk:cnode0"

sudo ./scripts/rpc.py nvmf_create_transport -t tcp -o -u 8192
sudo ./scripts/rpc.py nvmf_create_subsystem $NQN -a -s SPDK00000000000001 -r
sudo ./scripts/rpc.py bdev_aio_create /dev/nvme0n2 aio0
sudo ./scripts/rpc.py nvmf_subsystem_add_ns --uuid 80bc7acd-e032-40bc-acd6-45bc7bb96690 --nguid 2016595ab52040fbac2e7297c5e5fbfa --eui64 36dbe32e8a9c40c1 $NQN aio0
sudo ./scripts/rpc.py nvmf_subsystem_add_listener -t tcp -a $IP -s $PORT $NQN
sudo ./scripts/rpc.py nvmf_subsystem_listener_set_ana_state $NQN -t tcp -a $IP -s $PORT -n optimized

popd
