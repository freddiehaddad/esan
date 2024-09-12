# NVMe-of Multipath with VDO

This configuration uses two VMs with one configured as the initiator and the other as the target.

## Common Commands

On each VM run the following commands:

```text
sudo modprobe kvdo
sudo modprobe nbd
```

## Target VM

> [!NOTE]
> SPDK uses a unique partition type GUID that exposes the bdev as a Linux block device via NBD.  Once a partition is created and the partition type GUID set, it will be automatically exposed as `nvme0n1p1` in SPDK applications.

Run the following commands:

```text
cd /opt/spdk
sudo ./scripts/setup.sh
sudo ./build/bin/nvmf_tgt -m 0xfffff
```

```text
cd /opt/spdk
IP=$(ip address show dev eth0 | grep -oP "inet \K\d+.\d+.\d+.\d+") && echo $IP
sudo ./scripts/rpc.py nvmf_create_transport -t tcp -o -u 8192
sudo ./scripts/rpc.py nvmf_create_subsystem nqn.2024-09.io.spdk:cnode0 -a -s SPDK00000000000001 -r
sudo ./scripts/rpc.py bdev_aio_create /dev/nvme0n2 aio0
sudo ./scripts/rpc.py nbd_start_disk aio0 /dev/nbd0
sudo parted -s /dev/nbd0 mklabel gpt
sudo parted -s /dev/nbd0 mkpart spdk-vdo '0%' '50%'
sudo sgdisk -t 1:6527994e-2c5a-4eec-9613-8f5944074e8b /dev/nbd0
sudo rpc.py nbd_stop_disk /dev/nbd0
sudo ./scripts/rpc.py nbd_start_disk aio0 /dev/nbd0
sudo vgcreate vdovg /dev/nbd0p1
sudo lvcreate --type vdo --compression y --deduplication y --extents 262143 --name vdolv vdovg
sudo ./scripts/rpc.py nvmf_subsystem_add_ns --uuid 80bc7acd-e032-40bc-acd6-45bc7bb96690 --nguid 2016595ab52040fbac2e7297c5e5fbfa --eui64 36dbe32e8a9c40c1 nqn.2024-09.io.spdk:cnode0 aio0
sudo ./scripts/rpc.py nvmf_subsystem_add_listener -t tcp -a $IP -s 4420 nqn.2024-09.io.spdk:cnode0
sudo ./scripts/rpc.py nvmf_subsystem_add_listener -t tcp -a $IP -s 4421 nqn.2024-09.io.spdk:cnode0
```

If everything is configured correctly, you should see the following:

```text
$ lsblk
nbd0                      43:0    0     64T  0 disk
└─nbd0p1                  43:1    0     32T  0 part
  └─vdovg-vpool0_vdata   253:6    0   1024G  0 lvm
    └─vdovg-vpool0-vpool 253:7    0 1018.1G  0 lvm
      └─vdovg-vdolv      253:8    0 1018.1G  0 lvm
nvme0n2                  259:5    0     64T  0 disk
```

## Initiator VM

```
sudo modprobe nvme-tcp
sudo nvme connect --nqn nqn.2024-09.io.spdk:cnode0 --traddr 10.0.0.5 --trsvcid 4420 --transport tcp
sudo nvme connect --nqn nqn.2024-09.io.spdk:cnode0 --traddr 10.0.0.5 --trsvcid 4421 --transport tcp
sudo sh -c 'echo round-robin > /sys/class/nvme-subsystem/nvme-subsys1/iopolicy'
```

If everything is configured correctly, you should see the following:

```text
$ lsblk
nvme1n1                  259:6    0     64T  0 disk
└─nvme1n1p1              259:7    0     32T  0 part
  └─vdovg-vpool0_vdata   253:6    0   1024G  0 lvm
    └─vdovg-vpool0-vpool 253:7    0 1018.1G  0 lvm
      └─vdovg-vdolv      253:8    0 1018.1G  0 lvm
```

Confirming compression and deduplication state:

```text
$ sudo lvs -o+vdo_compression,vdo_compression_state,vdo_deduplication
  LV     VG     Attr       LSize     Pool   Origin Data%  Meta%  Move Log Cpy%Sync Convert VDOCompression VDOCompressionState VDODeduplication
  vdolv  vdovg  vwi-a-v---  1018.05g vpool0        0.10                                           enabled online                       enabled
  vpool0 vdovg  dwi------- <1024.00g               0.56                                           enabled online                       enabled
```

Sample fio commands to run:

```text
sudo fio --filename=/dev/mapper/vdovg-vdolv --size=1G --rw=write --bs=8K --ioengine=libaio --runtime=300 --numjobs=1 --name=vdo --iodepth=1 --buffered=0 --direct=1 --time_based
sudo fio --filename=/dev/mapper/vdovg-vdolv --size=1G --rw=write --bs=8K --ioengine=libaio --runtime=300 --numjobs=1 --name=vdo --iodepth=1 --buffered=0 --direct=1 --fsync=1 --time_based
```
