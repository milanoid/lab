
_OCI_ - Open Container Initiative

_Docker_ - is implementation of OCI, another is Podman

### Evolution of virtualization


### 0. bare metal server

### 1. virtual machines

- hypervisors (VMWare)
- each VM having its own kernel
- better utilization
- each VM is a full OS (creates overhead)

### 2. Containers

- one kernel shared with all containers
- no overhead -> more containers can run on the same HW



### Containers

- based on core linux feature
- isolation via namespaces

#### demo - create a new namespace

```bash
pstree -p
systemd(1)─┬─ModemManager(1264794)─┬─{ModemManager}(1264848)
           │                       ├─{ModemManager}(1264850)
           │                       └─{ModemManager}(1264853)
           ├─agetty(973)
           ├─containerd-shim(3170)─┬─node_exporter(3326)─┬─{node_exporter}(3367)
           │                       │                     ├─{node_exporter}(3368)
           │                       │                     ├─{node_exporter}(3369)
           │                       │                     ├─{node_exporter}(3370)
           │                       │                     └─{node_exporter}(3438)
```

- systemd has process id 1 - the initial process

```bash
ps ax
    PID TTY      STAT   TIME COMMAND
      1 ?        Ss     0:29 /usr/lib/systemd/systemd --system --deserialize=103
```


```bash
# unshare - run program in new namespaces
sudo unshare --fork --pid --mount-proc bash

# I am now in a new PID=1
ps aux
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root           1  0.0  0.0   7604  4352 pts/1    S    10:13   0:00 bash
root          24  0.0  0.0  10884  4480 pts/1    R+   10:14   0:00 ps aux

# looks very different
pstree
bash───pstree
```

- when in this new namespace the process (bash) does not know anything about the rest of the system (in other namespaces)
- each namespace could use all the resources (memory)
- this needs to be controlled -> `cgroups`

##### cgroups

- control groups 
- (this container can use max x MB of memory, CPU etc.)

```bash
# create a cgroup
sudo mkdir /sys/fs/cgroup/julius

# set 10 MB memory limit to that cgroup
echo 10000000 | sudo tee /sys/fs/cgroup/julius/memory.max

## put the current shell in the cgroup
# echo $$ -> get pid of the current shell
echo $$ | sudo tee /sys/fs/cgroup/julius/cgroup.procs

# try to allocate more memory than allowed
head -c 15M /dev/zero | tail
killed

# check journalctl for OOM message

# cleanup
sudo rmdir /sys/fs/cgroup/julius
```

- [ ] didn't killed that on my machine, repeat


Back to containers - each container:

- has namespaces assigned
- and its cgroup limits


### Union file system

- system of layers
- https://www.grant.pizza/blog/overlayfs/
- each layer can be re-used by multiple containers (prevents data duplication)

```
┌─────────────────────────────────┐
│   Container Layer (read-write)  │  ← Your changes at runtime
├─────────────────────────────────┤
│   App Code Layer (read-only)    │
├─────────────────────────────────┤
│   Dependencies Layer (read-only)│
├─────────────────────────────────┤
│   Base Image Layer (read-only)  │
└─────────────────────────────────┘
```

