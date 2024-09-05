# Multipath Test Results

## QD-32 

Summary

- 2024-09-05 03:37:23 UTC
- numjobs=4
- iodepth=8
- duration=5m

Command:

```text
sudo fio --filename=/dev/nvme1n1 --rw=write --direct=1 --bs=8K --ioengine=libaio --runtime=300 --time_based --group_reporting --name=seq_write --numjobs=4 --iodepth=8
```

Result:

```text
seq_write: (g=0): rw=write, bs=(R) 8192B-8192B, (W) 8192B-8192B, (T) 8192B-8192B, ioengine=libaio, iodepth=8
...
fio-3.35
Starting 4 processes
Jobs: 4 (f=4): [W(4)][100.0%][w=514MiB/s][w=65.8k IOPS][eta 00m:00s]
seq_write: (groupid=0, jobs=4): err= 0: pid=171654: Thu Sep  5 03:42:27 2024
  write: IOPS=65.5k, BW=512MiB/s (537MB/s)(150GiB/300001msec); 0 zone resets
    slat (nsec): min=1261, max=413182, avg=4656.16, stdev=2173.72
    clat (usec): min=232, max=16298, avg=483.22, stdev=146.50
     lat (usec): min=257, max=16304, avg=487.88, stdev=146.45
    clat percentiles (usec):
     |  1.00th=[  310],  5.00th=[  330], 10.00th=[  347], 20.00th=[  371],
     | 30.00th=[  396], 40.00th=[  420], 50.00th=[  449], 60.00th=[  486],
     | 70.00th=[  529], 80.00th=[  578], 90.00th=[  660], 95.00th=[  742],
     | 99.00th=[  930], 99.50th=[ 1012], 99.90th=[ 1205], 99.95th=[ 1319],
     | 99.99th=[ 3097]
   bw (  KiB/s): min=426048, max=614464, per=100.00%, avg=524585.91, stdev=7754.44, samples=2396
   iops        : min=53256, max=76808, avg=65573.24, stdev=969.30, samples=2396
  lat (usec)   : 250=0.01%, 500=63.83%, 750=31.55%, 1000=4.08%
  lat (msec)   : 2=0.52%, 4=0.01%, 10=0.01%, 20=0.01%
  cpu          : usr=1.28%, sys=8.81%, ctx=14208393, majf=0, minf=256
  IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=100.0%, 16=0.0%, 32=0.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.1%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     issued rwts: total=0,19664989,0,0 short=0,0,0,0 dropped=0,0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=8

Run status group 0 (all jobs):
  WRITE: bw=512MiB/s (537MB/s), 512MiB/s-512MiB/s (537MB/s-537MB/s), io=150GiB (161GB), run=300001-300001msec

Disk stats (read/write):
  nvme1n1: ios=47/19657613, merge=0/0, ticks=635/9419768, in_queue=9420403, util=100.00%
```

## QD-32 

Summary

- 2024-09-05 03:47:26 UTC
- numjobs=8
- iodepth=4
- duration=5m

Command:

```text
sudo fio --filename=/dev/nvme1n1 --rw=write --direct=1 --bs=8K --ioengine=libaio --runtime=300 --time_based --group_reporting --name=seq_write --numjobs=8 --iodepth=4
```

Result:

```text
seq_write: (g=0): rw=write, bs=(R) 8192B-8192B, (W) 8192B-8192B, (T) 8192B-8192B, ioengine=libaio, iodepth=4
...
fio-3.35
Starting 8 processes
Jobs: 8 (f=8): [W(8)][100.0%][w=556MiB/s][w=71.2k IOPS][eta 00m:00s]
seq_write: (groupid=0, jobs=8): err= 0: pid=171908: Thu Sep  5 03:52:31 2024
  write: IOPS=76.8k, BW=600MiB/s (629MB/s)(176GiB/300001msec); 0 zone resets
    slat (nsec): min=1281, max=217756, avg=5237.12, stdev=1724.10
    clat (usec): min=228, max=13557, avg=411.30, stdev=110.99
     lat (usec): min=254, max=13564, avg=416.53, stdev=110.95
    clat percentiles (usec):
     |  1.00th=[  293],  5.00th=[  306], 10.00th=[  314], 20.00th=[  330],
     | 30.00th=[  347], 40.00th=[  363], 50.00th=[  383], 60.00th=[  408],
     | 70.00th=[  437], 80.00th=[  478], 90.00th=[  553], 95.00th=[  611],
     | 99.00th=[  750], 99.50th=[  807], 99.90th=[  955], 99.95th=[ 1057],
     | 99.99th=[ 2343]
   bw (  KiB/s): min=497744, max=707536, per=100.00%, avg=614458.20, stdev=4403.30, samples=4792
   iops        : min=62218, max=88442, avg=76807.27, stdev=550.41, samples=4792
  lat (usec)   : 250=0.01%, 500=83.52%, 750=15.51%, 1000=0.90%
  lat (msec)   : 2=0.06%, 4=0.01%, 10=0.01%, 20=0.01%
  cpu          : usr=0.77%, sys=5.67%, ctx=20349047, majf=0, minf=171
  IO depths    : 1=0.1%, 2=0.1%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     issued rwts: total=0,23030324,0,0 short=0,0,0,0 dropped=0,0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=4

Run status group 0 (all jobs):
  WRITE: bw=600MiB/s (629MB/s), 600MiB/s-600MiB/s (629MB/s-629MB/s), io=176GiB (189GB), run=300001-300001msec

Disk stats (read/write):
  nvme1n1: ios=51/23022547, merge=0/0, ticks=817/9428569, in_queue=9429386, util=100.00%
```
