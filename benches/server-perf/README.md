# Measuring performance of the server: does it scale ?

With settings

```rust
// Number of files saved per minutes per client
const MIN_SAVE_PER_MINUTE: u16 = 2;
const MAX_SAVE_PER_MINUTE: u16 = 20;
// Number of client to put in a live session
const MIN_CLIENT_PER_SESSION: u16 = 20;
const MAX_CLIENT_PER_SESSION: u16 = 60;
```

## Start situation
700Ko of RAM + 0% CPU
```sh
> docker stats env-plx-1
CONTAINER ID   NAME        CPU %     MEM USAGE / LIMIT   MEM %     NET I/O          BLOCK I/O   PIDS 
e692576c9958   env-plx-1   0.00%     708KiB / 1.91GiB    0.04%     5.2kB / 1.56kB   0B / 0B     2 
```
With ~30 TCP connexions
```sh
> ss -s
Total: 217
TCP:   30 (estab 3, closed 14, orphaned 1, timewait 0)
```

## Adding 400 clients sending requests
It uses 53MB of RAM and 0.68% of CPU.
```sh
> docker stats env-plx-1
CONTAINER ID   NAME        CPU %     MEM USAGE / LIMIT    MEM %     NET I/O         BLOCK I/O   PIDS 
e692576c9958   env-plx-1   0.68%     52.84MiB / 1.91GiB   2.70%     882kB / 247kB   0B / 0B     2 
```
We can confirm the 30 passing to 423.
```sh
> ss -s
Total: 217
TCP:   423 (estab 2, closed 407, orphaned 7, timewait 0)
```
