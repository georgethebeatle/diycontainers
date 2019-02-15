# DIY Linux Containers

## What dis?

In this tutorial we are going to play with containers in order to better understand what is a container, how does it differ from a virtual machine and what do container engines such as `docker`, `rkt` and `lxc` do under the hood to create containers. While in real life you will likely be using one of these engines, it is really useful to understand the low level details in some depth in order to effectively and securely use containers as a development tool or as a part of a larger system's architecture.

## Why containers?

People have been dealing a lot with computers in the past few decades. This period saw great advancements in technology, both hardware and software, but there have been some recurring patterns. Despite the constant change of technology some problems need to be solved over and over again. Once you finish developing your program and want to publish it to a server you start facing problems. Is it going to work at all? It works on your development machine, but does the server have all dependencies installed? Is it going to be secure? You know that there are other programs running on that server so some of them might mess with your program and its state. Or they might consume all available resources forcing it to crash. Portability, security and isolation have been hot topics in the world of computers almost since the very beginning. 

One early way to address these problems was to use multiple OS users. Every user would have limited permissions, preventing it from seeing and modifying files owned by other users. While this model worked, what wasn't so great about it was the fact that all apps were still running on the same host, so a malicious app could still drain all the resources. This model also did not address portability.

So at some point people invented virtual machines. With virtual machines we are giving each app not just a user, but a whole OS. This is way more secure since apps are no longer running side by side on the same host. What's more each VM has its own image, which also solves the portability problem - distribute your program as a VM image and it would run everywhere. The problem with VMs is that they are slow to create and expensive to manage. After all you are starting a whole OS just to run your app. Isn't there a better way?

This is exactly what containers are trying to explore. Just like VMs, they are addressing the problems of isolation, security and portability, but are cheaper, more lightweight and way more flexible.

## What is a container?

There are multiple definitions of a container. Some popular ones are 'lightweight virtualization' and the shipping container analogy. I am not going to confuse you with yet another one. Instead, let's create a container using docker and explore how it looks like both from the inside and from the outside. 


First of all we need a linux machine. They don't call them linux containers for nothing, right? In case you are running on Windows or MacOS you can spin up an ubuntu virtual machine by executing the following script:

```
git clone https://github.com/georgethebeatle/diycontainers.git
cd diycontainers
vagrant up
```

This is going to create an ubuntu VM that is running the docker daemon. We are going to refer to it as the 'container host' or just 'host'.

For the rest of the tutorial we are going to be using two terminal windows tiled next to each other. We are going to refer to them as the 'left terminal' and the 'right terminal'. We are going to open shell sessions to the container host in both terminal windows. We will use the left terminal to run commands in the container and the right terminal to run commands on the host. 

After the vm is up and running make sure you open shell sessions by running the following commands in both terminal windows:

```
vagrant ssh
sudo su -
```

Now let's create a container with docker. Run this command in your left terminal:

```
$ docker run -it busybox
```

This should result in a shell running in the newly created container. Now let's run some commands in the container:

```
$ ls -la /
drwxr-xr-x    1 root     root          4096 Feb 11 14:00 .
drwxr-xr-x    1 root     root          4096 Feb 11 14:00 ..
-rwxr-xr-x    1 root     root             0 Feb 11 14:00 .dockerenv
drwxr-xr-x    2 root     root         12288 Dec 31 18:16 bin
drwxr-xr-x    5 root     root           360 Feb 11 14:00 dev
drwxr-xr-x    1 root     root          4096 Feb 11 14:00 etc
drwxr-xr-x    2 nobody   nogroup       4096 Dec 31 18:16 home
dr-xr-xr-x  189 root     root             0 Feb 11 14:00 proc
drwx------    1 root     root          4096 Feb 11 14:00 root
dr-xr-xr-x   13 root     root             0 Feb 11 12:07 sys
drwxrwxrwt    2 root     root          4096 Dec 31 18:16 tmp
drwxr-xr-x    3 root     root          4096 Dec 31 18:16 usr
drwxr-xr-x    4 root     root          4096 Dec 31 18:16 var

$ ps aux
PID   USER     TIME  COMMAND
    1 root      0:00 sh
    7 root      0:00 ps aux

$ uname -a
Linux f758f8c61110 4.15.0-33-generic #36-Ubuntu SMP Wed Aug 15 16:00:05 UTC 2018 x86_64 GNU/Linux
```

Let's run the same commands on the host and compare the output. In your right terminal execute the following:

```
$ ls -la /
vagrant@ubuntu-bionic:~$ ls -la /
total 96
drwxr-xr-x  24 root    root     4096 Feb 11 15:38 .
drwxr-xr-x  24 root    root     4096 Feb 11 15:38 ..
-rw-r--r--   1 root    root        0 Feb 11 15:38 I_AM_THE_HOST
drwxr-xr-x   2 root    root     4096 Feb 11 15:33 bin
drwxr-xr-x   3 root    root     4096 Feb 11 15:35 boot
drwxr-xr-x  16 root    root     3660 Feb 11 15:32 dev
drwxr-xr-x  92 root    root     4096 Feb 11 15:36 etc
drwxr-xr-x   4 root    root     4096 Feb 11 15:32 home
...
drwxr-xr-x  13 root    root     4096 Sep  3 16:06 var
lrwxrwxrwx   1 root    root       30 Feb 11 15:34 vmlinuz -> boot/vmlinuz-4.15.0-45-generic
lrwxrwxrwx   1 root    root       30 Sep  3 16:04 vmlinuz.old -> boot/vmlinuz-4.15.0-33-generic

$ ps aux
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.5  0.9 159888  9400 ?        Ss   15:32   0:06 /lib/systemd/systemd --system --deserialize 34
root         2  0.0  0.0      0     0 ?        S    15:32   0:00 [kthreadd]
...
syslog   12030  0.0  0.3 263036  3356 ?        Ssl  15:34   0:00 /usr/sbin/rsyslogd -n
root     12488  0.0  0.0  25376   244 ?        Ss   15:34   0:00 /sbin/iscsid
root     12491  0.0  0.5  25880  5300 ?        S<Ls 15:34   0:00 /sbin/iscsid
root     12699  0.0  1.6 170936 16316 ?        Ssl  15:34   0:00 /usr/bin/python3 /usr/bin/networkd-dispatcher --run-startup-triggers
root     12905  0.0  0.6 288876  6268 ?        Ssl  15:34   0:00 /usr/lib/policykit-1/polkitd --no-debug
root     14576  0.0  0.5  72296  5496 ?        Ss   15:34   0:00 /usr/sbin/sshd -D
root     30310  0.2  4.1 809224 42004 ?        Ssl  15:36   0:01 /usr/bin/containerd
root     31342  0.0  6.7 782564 68016 ?        Ssl  15:36   0:00 /usr/bin/dockerd -H fd://

uname -a
Linux f758f8c61110 4.15.0-33-generic #36-Ubuntu SMP Wed Aug 15 16:00:05 UTC 2018 x86_64 GNU/Linux
```

Comparing the outputs, it seems that the container is behaving a lot like a VM. It is seeing its own image and its own set of processes (with much larger pid numbers) that have nothing to do with those of the host. From the container's point of view it looks like it is running on a different machine. However, the kernel version (displayed by `uname -a`) looks exactly the same.

Now let's trigger a long running process in the container. In your left terminal execute:

```
sleep 9999
```

While it is sleeping go to your right terminal and list the process tree:

```
$ ps auxf | grep -C3 "[s]leep 9999"
root     30310  0.2  4.2 957840 43216 ?        Ssl  15:36   0:03 /usr/bin/containerd
root      8517  0.0  0.4   9324  4976 ?        Sl   16:01   0:00  \_ containerd-shim -namespace moby -workdir /var/lib/contain
erd/io.containerd.runtime.v1.linux/moby/f758f8c6111068310c25c742624a091a96253bc466c7a1a2fad7f1d720012c13 -address /run/contain
erd/containerd.sock -containerd-binary /usr/bin/containerd -runtime-root /var/run/docker/runtime-runc
root      8540  0.0  0.0   1296     4 pts/0    Ss   16:01   0:00      \_ sh
root      8596  0.0  0.0   1280     4 pts/0    S+   16:01   0:00          \_ sleep 9999
root     31342  0.0  8.3 874524 84344 ?        Ssl  15:36   0:00 /usr/bin/dockerd -H fd://
vagrant   8346  0.0  0.7  76612  7660 ?        Ss   15:43   0:00 /lib/systemd/systemd --user
vagrant   8347  0.0  0.2 193872  2672 ?        S    15:43   0:00  \_ (sd-pam)
```

It looks like the sleep we triggered in the container is actually a process on the host. It is a child of a process called `containerd-shim`, which is a child of another process called `containerd`. If you google for containerd you will find out that it is nothing but the container runtime that docker uses underneath. Let's see what would happen if we try to kill that process. In the right terminal:

```
kill 8596
```

As a result the sleep in the container exited. This would not be possible if we were running sleep in a VM. What is even more interesting - if you try running `reboot` in the left terminal (in the container) nothing will happen.

So to sum up our container looks a lot like a VM in that it has its own view of the filesystem and the process tree, but it does not quite behave like one. It is sharing the same kernel with the host, processes in the container are visible from the host, we cannot do things like reboot. A container is a set of processes running in isolation.

## Containers do not exist

Yeah, that's right! In the linux kernel there is no single native object that represents a container. Instead, a container is composed of lower level kernel primitives like processes, namespaces and cgroups. We already saw that a container is essentially a set of processes running on the host. But what are namespaces and cgroups? Put simply these are kernel primitives for process isolation. Each linux namespace isolates a certain aspect of the process by giving it its own view of some part of the system, like the filesystem or the process tree. Here are the main types of linux namespaces:
- Mount: gives the process its own view of the root filesystem
- Pid: gives the process its own view of the process tree
- User: giver the process its own view of the OS users
- others: There are a few more, but they are not as visible, so we are going to focus on the three above.

Each process in the linux OS is running in a namespace of each type. Namespaces form a hierarchy. Most of the processes on the host are sharing the same set of namespaces at the root of that hierarchy. As a result they have the same view of the system - they are seeing the same files and the same process tree. The root user can create child namespaces using the `unshare` command. A call to unshare looks like this:

```
unshare [options] [<program> [<argument>...]]
```

It takes options, which are telling it what namespaces top unshare and what program to run in the unshared namespaces. As a result we get a new process that is running in a new set of namespaces, so it has a different view of the system. It can modify certain aspects of the system without affecting the rest of the processes on the host. When this process exists the linux kernel is going to deallocate the new namespaces and the changes will go away. That's the basic lifecycle of a linux namespace.

Cool, what about cgroups? Cgroup stands for 'control group'. Cgroups are another set of primitives which are used to control process resource usage, by setting resource limits. They are completely orthogonal to namespaces. For example you can create a new memory cgroup that sets a memory limit. You can join your process to that cgroup and it won't be able to allocate more memory than the amount specified in the cgroup. Some important types of cgroups are `memory`, `cpu` and `blkio`.  Cgroups play an important role in container isolation, but have less visible effects than namespaces, so we are not going to explore them today.


## Let's build a container

Let's finally get our hands dirty and start building our own container using namespaces and the `unshare` command. We are going to need just a clean linux distro and a root filesystem to use as an image for our container. We are not going to need docker.

In order to prepare your terminals type `exit` in the left one. This will kill the docker container we created earlier and get you back to the host. In both terminals make sure you are still logged in the vagrant VM as the `root` user. You need to be root in order to create new namespaces.

### The mount namespace

So we need to create a process and some namespaces. We will start with the mount namespace. According to the kernel docs `Mount namespaces provide isolation of the list of mount points seen by the processes in each namespace instance.` What does that mean? In the Linux OS the filesystem has a single root - a directory named `/`. All other files and directories are children and grandchildren of `/`. The filesystem that starts on `/` is known as a root filesystem (rootfs) or the machine image. If we want to look at another fileystem, for example a USB stick or some network storage, we need to mount the new filesystem somewhere in the root filesystem, so that we can browse it. For example we might mount a USB stick on `/mnt/myusbstick` and if it is correctly formatted we will be able to see its contents under that path. `/mnt/myusbstick` is a mountpoint, since it is the root of a filesystem that is different from the root filesystem. The list of all mount points is known as the mount table. The only thing that the mount namespace does is to provide the new process with a unique copy of the mount table. In the beginning it is an exact clone of the parent mount namespace, but any mounts that the new process does go to its own mount table and are not visible on the host. Let's see this in action. In your left terminal, run this command:

```
unshare -m /bin/sh
```

This is going to start a new shell process in its own mount namespace. Let's inspect the mount tables from both the unshared shell and the host. Run `cat /proc/mounts` in both windows. You will notice that they are identical. The mount table in the new mount namespace starts off as a copy of the host's mount table. We can count the number of mount points by running `cat /proc/mounts | wc -l` and it will be the same on the host and in the new namespace. On my machine this number happens to be 33.

You might wonder what is this `proc` directory that we are looking at. Let's spend a minute talking about it since it is an important concept. The `/proc` directory itself is a mount point. We can confirm this by executing this on the host:

```
$ mountpoint /proc
/proc is a mountpoint
```

If it is a mountpoint this means there is a filesystem that is mounted under it. This is the `procfs` filesystem - it is a special virtual filesystem. It is not associated with a block storage device such as a disk or a USB, but it is directly exposing runtime information about the state of the system, such as the mount tables and the processes that are currently running. It contains many virtual files that give you real time info about certain aspects of the system. For example `/proc/uptime` tells you how long has the machine been running and `/proc/meminfo` gives you detailed information about allocated memory.

Back to what we were doing. Now that we have a new mount namespace, let's mount something. In the left terminal navigate to `/tmp/playground` and list the `rootfs` directory.

```
$ cd /tmp/platground
$ ls rootfs
I_AM_THE_CONTAINER  bin  linuxrc  sbin  usr
```

The `rootfs` directory is the busybox image that we will be using as a rootfs for our container. Let's bind mount the rootfs.

```
mount --bind rootfs/ rootfs/
```

We just created a new mount point and mounted the contents of the `rootfs` directory as a new filesystem. The `--bind` option tells the mount command that the filesystem data is not coming from a device such as a disk or a flash drive, but from a local directory. The first argument is the path to the source dorectory and the second argument is the path where we want to mount it. In our case we are mounting the rootfs dir onto itself. We are doing this just to get `/tmp/playground/rootfs` in the mount table. You will see why we need it there in a second.

Now that we have a mount point in the contiainer let's run `cat /proc/mounts | wc -l` in both terminal windows. This time is is reporting 34 mount points in the container and 33 on the host. We are already witnessing some isolation. Unfortunately listing `/` still yields the same results in both terminal windows. What are we missing?

Well, just unsharing a new mount namespace and bind mounting a rootfs is not enough to give the container its own vie of the root filesystem. Technically both shell processes still have the same rootfs and this is the rootfs of the ubuntu VM. In order to change the rootfs of the container we need to run the `pivot_root` command. Here is how it is used:

```
pivot_root new_root put_old
```

This command will change the root filesystem of the calling process. The first argument is the new rootfs. It needs to be a mountpoint - that's why we needed to bind mount the rootfs. The second argument is a path in the new rootfs where `pivot_root` is going to put the old ubuntu VM rootfs. Let's try it:

```
$ mkdir rootfs/old
$ pivot_root rootfs rootfs/old
$ cd /
$ ls /
I_AM_THE_CONTAINER  bin  linuxrc  sbin  usr
```

Now let's list `/` on the host:

```
$ ls /
I_AM_THE_HOST  boot  etc   initrd.img      lib    lost+found  mnt  proc  run   snap  sys  usr      var      vmlinuz.old
bin            dev   home  initrd.img.old  lib64  media       opt  root  sbin  srv   tmp  vagrant  vmlinuz
```

Cool! Our unshared process looks a lot more like the docker container we were playing with in the beginning! However we still have access to the old rootfs - it can be found under `/old` in the container. Let's check:

```
$ ls /old
I_AM_THE_HOST   etc             lib             mnt             run             sys             var
bin             home            lib64           opt             sbin            tmp             vmlinuz
boot            initrd.img      lost+found      proc            snap            usr             vmlinuz.old
dev             initrd.img.old  media           root            srv             vagrant
```

It is there. If we want we can unmount it via `umount -l /old`

Let's list the process tree - run `ps aux` in both terminals. In both places we see the same set of processes which is not what we want. Our container seems to be quite leaky - like a box with just one side. Let's fix that by moving on to the next namespace. Before we do that do not forget to exit from the container in the left terminal.

### The pid namespace

Let's isolate our container eve further by unsharing both mount and pid namespaces. Execute the following inthe left terminal window:

```
unshare -m -p -f /bin/sh
```

We have added two new options to `unshare`. The `-p` option is telling `unshare` to create a new pid namespace. The `-f` option makes `unshare` fork a child before execing our program. We need to do that because of how pid namespaces work. According to the man page `the first child created by a process after a call to unshare using the CLONE_NEWPID flag has the PID 1, and is the "init" process for the namespace`. So the `-f` is just making sure that the shell process will be the first process in the new pid namespace. Let's confirm that by printing the container shell pid:

```
$ echo $$
1
```

Looks like we are the first process in the container. Pretty cool!

Before we dive into the world of pids lets quickly configure the rootfs as we did before:

```
cd /tmp/playground
mount --bind rootfs/ rootfs/
pivot_root rootfs/ rootfs/old
umount -l /old
cd /
```

Now let's list all the processes in the container:

```
$ ps aux
PID   USER     TIME  COMMAND
ps: can't open '/proc': No such file or directory
```

It looks weird but it is expected. The ps command is reading the `procfs` filesystem in order to get information about the running processes. It expects to find this filesystem on `/proc` but it is not there so it is failing. Let's fix that. Run this in the container:

```
mkdir /proc
mount -t proc none /proc
```

Now run `ps aux` again:

```
$ ps aux
PID   USER     TIME  COMMAND
    1 0         0:00 /bin/sh
    7 0         0:00 ps auxf
```

Voila! We have process tree isolation now. Exactly like we did in the docker container! We are doing pretty good! Our container is still not absolutely safe though. Let's run a long sleep in the container on the left:

```
sleep 999
```

While it is sleeping run the following on the host:

```
$ ps aux | grep "[s]leep 999"
root      7728  0.0  0.0   3224     4 pts/0    S+   14:55   0:00 sleep 999
```

As you can see it is running as the root user. This is what we call a privileged contianer. Running your program as the root user is generally discouraged practice in the linux world. The root user is the most privileged user on the system and can do anything, so if a malicious user manages to hack your program they can cause a lot of damage. However if your program runs as an unprivileged user, even if it gets hacked, the hacker would not be able to affect other programs. Let's try to build an unprivileged container. Before that make sure you exit from the current container.

### User namespace

First of all make sure both terminal windows are logged in the ubuntu VM as user vagrant:

```
su vagrant
```

Then run the `unshare` command in the left terminal as usual:

```
unshare -U -m -p -f /bin/sh
```

Now let's check what user are we running as in the container. Run this on the left:

```
$ whoami
nobody
```

Interesting. If you run this on the host you are going to get `vagrant` as the user name. What happened is that we created a new user namespace, but did not initialize it. That's why we are nobody. User namespaces are a bit different from the others. They are the only type of namespace that you can unshare as an unprivileged user (that's the whole point). The cool thing about running in a user namespace is that you can be `root` (uid 0) inside the namespace, but `vagrant` (uid 1000) in the parent user namespace. This way you have privileges only in the container. This is achieved by the so called user mappings. User mappings need to be written immediately after the user namespace is unshared. They are writen to a special file with path `/proc/<pid>/uid_map`. This is a file in the procfs. This filesystem keeps a directory for each running process. The name of the directory is the same as the process pid as shown by `ps`. So let's find out the pid of our container. Run this on the host:

```
$ ps auxf | grep -A1 [u]nshare
vagrant   7773  0.0  0.0   7912   800 pts/0    S    15:07   0:00  |   \_ unshare -U -m -p -f /bin/sh
vagrant   7774  0.0  0.0   4628   788 pts/0    S+   15:07   0:00  |      \_ /bin/sh
```

Looks like our `sh` process has a pid of `7774`. Let's list the user mappings for this process:

```
cat /proc/7774/uid_map
```

It is empty. This is the reason why our container currently thinks it is nobody. Let's write a sensible mapping. Mappings are written in the following format:

```
<uid> <puid> <size>
```

The first number is uid in the new userns, the second number is uid in its parent namespace and the last number is the size of the mapping. For example a mapping with size 2 is going to map `uid` to `puid` and `uid+1` to `puid+1`. In order to map uid 0 in our new user namespace to uid 1000 in its parent (the user namespace of the host) we need to write `0 1000 1` to the mapping file. Let's do it. Run the following command on the host:

```
echo 0 1000 1 > /proc/7774/uid_map
```

And now let's check the container user again:

```
$ whoami
root
```

Now, that's somethig. Our shell thinks it is `root`, but if we look at pid `7774` on the host is is run by user `vagrant`.

```
$ ps aux | grep [7]774
vagrant   7774  0.0  0.0   4628   788 pts/0    S+   15:07   0:00 /bin/sh
```
If we want we can quickly isolate the rootfs and process tree as we did before:

```
cd /tmp/playground
mount --bind rootfs/ rootfs/
pivot_root rootfs/ rootfs/old
umount -l /old
cd /
mount -t proc none /proc
```

And we have build a decently isolated container. Sure, there's a lot more to do, but I think you should be getting the idea by now, so I am going to stop now.

Here are all the steps that we explored today:

```
# on the host
unshare -U -m -p -f
echo 0 1000 1 > /proc/pid/uid_map

#in the container
mount --bind rootfs/ rootfs/
pivot_root rootfs/ rootfs/old
umount -l /old
cd /
mount -t proc none /proc
```

## Recap

There we are building containers! What did we learn in the process? 
- Containers don't exist
- A container is just a set of processes running in isolation
- We can isolate processes as little or as much as we like using namespaces.

Creating containers is like playing with lego. You can use the primitive building block and you can build whatever you need with them. You do not need to use all namespaces, you can create containers that share namespaces, etc. Docker is doing just that under the hood. Docker is just one of the lego sets. 

