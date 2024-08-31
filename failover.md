# Instructions for Configuring Failover Tests

## Target 1 VM (Active)

In a terminal run:

```text
cd /opt/spdk
sudo ./scrips/setup.sh
sudo ./build/bin/nvmf_tgt -m 0xfff
```

In another terminal run:

```text
cd /opt/spdk
IP=$(ip address show dev eth0 | grep -oP "inet \K\d+.\d+.\d+.\d+")
PORT=4420
sudo ./scripts/rpc.py nvmf_create_transport -t tcp -o -u 8192
sudo ./scripts/rpc.py nvmf_create_subsystem nqn.2024-08.io.spdk:cnode0 -a -s SPDK00000000000001 -r
sudo ./scripts/rpc.py bdev_aio_create /dev/nvme0n2 aio0
sudo ./scripts/rpc.py nvmf_subsystem_add_ns --uuid 80bc7acd-e032-40bc-acd6-45bc7bb96690 --nguid 2016595ab52040fbac2e7297c5e5fbfa --eui64 36dbe32e8a9c40c1 nqn.2024-08.io.spdk:cnode0 aio0
sudo ./scripts/rpc.py nvmf_subsystem_add_listener -t tcp -a $IP -s $PORT nqn.2024-08.io.spdk:cnode0
```

## Target 2 VM (Passive)

In a terminal run:

```text
cd /opt/spdk
sudo ./scrips/setup.sh
sudo ./build/bin/nvmf_tgt -m 0xfff
```

In another terminal run:

```text
cd /opt/spdk
IP=$(ip address show dev eth0 | grep -oP "inet \K\d+.\d+.\d+.\d+")
PORT=4420
sudo ./scripts/rpc.py nvmf_create_transport -t tcp -o -u 8192
sudo ./scripts/rpc.py nvmf_create_subsystem nqn.2024-08.io.spdk:cnode0 -a -s SPDK00000000000001 -r
sudo ./scripts/rpc.py bdev_aio_create /dev/nvme0n2 aio0
sudo ./scripts/rpc.py nvmf_subsystem_add_ns --uuid 80bc7acd-e032-40bc-acd6-45bc7bb96690 --nguid 2016595ab52040fbac2e7297c5e5fbfa --eui64 36dbe32e8a9c40c1 nqn.2024-08.io.spdk:cnode0 aio0
sudo ./scripts/rpc.py nvmf_subsystem_add_listener -t tcp -a $IP -s $PORT nqn.2024-08.io.spdk:cnode0
```

## Initiator VM

The first step is to generate a configuration file for `bdevperf` which is used to drive the failover test.

### Generate a Configuration File

In a terminal run:

```text
cd /opt/spdk
sudo ./scrips/setup.sh
sudo ./build/bin/spdk_tgt -m 0xfff
```

In another terminal run:

```text
cd /opt/spdk
sudo ./scripts/rpc.py bdev_nvme_set_options -r -1
sudo ./scripts/rpc.py bdev_nvme_attach_controller -b Nvme0 -t tcp -a 10.1.0.5 -s 4420 -f ipv4 -n nqn.2024-08.io.spdk:cnode0 -q nqn.2024-08.io.spdk -l -1 -o 10
sudo ./scripts/rpc.py bdev_nvme_attach_controller -b Nvme0 -t tcp -a 10.1.0.6 -s 4420 -f ipv4 -n nqn.2024-08.io.spdk:cnode0 -q nqn.2024-08.io.spdk -x multipath -l -1 -o 10
sudo ./scripts/rpc.py save_config > ~/bdevperf_failover.json
```

### Test Initialization

Return to the window where `spdk_tgt` is running and press `ctrl+c` to kill the process.

Run the following command:

```text
sudo ./build/examples/bdevperf -m 0xfff -z -q 32 -o 8192 -w write -ll -t 300 -c ~/bdevperf_failover.json
```
NOTE: You can tweak the configuration parameters before running the command (see `bdevperf --help`).

In another terminal run:

```text
sudo PYTHONPATH=$PYTHONPATH:/opt/spdk/python ./examples/bdev/bdevperf/bdevperf.py perform_tests
```

## Observing the Test

In each of the target VMs you can run the following commands in separate terminals to watch network traffic.

```text
watch -n 1 ss -t
```

```text
watch -n 1 ./scripts/iostat.py
```

## Triggering the Failover

In the terminal window where `nvmf_tgt` process is running on Target VM 1, press `ctrl+c` to kill the process. Observe the traffic on Target VM 2.
