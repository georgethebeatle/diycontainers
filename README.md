# DIY Linux Containers

## What dis?

In this tutorial we are going to play with containers in order to better understand what is a container, how does it differ from a virtual machine and what do container engines such as `docker`, `rkt` and `lxc` do under the hood to create containers. While in real life you are definitely going to be using one of these, it is really useful to understand the low level details in some depth in order to effectively and securely use containers as a development tool or as a part of a larger system's architecture.

## Why containers?

People have been dealing a lot with computers in the past few decades. This period saw great advancements in technology, both hardware and software, but there have been some recurring patterns. Despite the constant change of technology some problems need to be solved over and over again. Once you finish developing your program and want to publish it to a server you start facing problems. Is it going to work at all? It works on your development machine, but does the server have all dependencies installed? Is it going to be secure? You know that there are other programs running on that server so some of them might mess with your program and its state. Or consume all available resources forcing it to crash. Portability, security and isolation have been hot topics in the world of computers since the very beginning. 

One early way to address security and isolation was to use multiple OS users. Every user would have limited permissions, preventing it from seeing files owned by other users. While this model worked all apps were still running on the same host and it was hard to guarantee that a malicious user or program wouldn't mess with others. This model also did not address portability.

So people invented virtual machines. With virtual machines we are giving each app not just a user, but a whole OS. This is way more secure since apps are no longer sibling processes on the same host. What's more each VM has its own image, which also solves the portability problem - distribute your program as a VM image and it would run everywhere. The problem with VMs is that they are slow and expensive to manage. After all you are starting a whole OS just to run your app. Isn't there a better way?

This is exactly what containers are trying to prove. Just like VMs, they are addressing the problems of isolation, security and portability, but are cheaper, more lightweight and more flexible.

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

If we compare the outputs we can say that the container is behaving like a VM. It is seeing its own image and its own set of processes (with much larger pid numbers) that have nothing to do with those of the host. From the container's point of view it is running on a different machine. However, the kernel version (displayed by `uname -a`) looks exactly the same.

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

It looks like the sleep we triggered in the container is actually a process on the host. It is a child of a process called `containerd-shim`, which is a child of another process called `containerd`. If you google for containerd you will find out that it the container runtime that docker is using. Let's see what would happen if we try to kill that process. In the right terminal:

```
kill 8596
```

As a result the sleep in the container exited. This would not be possible if we were running sleep in a VM.

What is even more interesting - if you try running `reboot` in the left terminal nothing will happen.

So our container looks a lot like a VM in that it has its own view of the filesystem and the process tree, but it does not quite behave like one. It is sharing the same kernel with the host, processes in the container are visible from the host, we cannot do things like reboot. A container is technically a set of processes running in isolation.

## Building Blocks

## Let's build one
