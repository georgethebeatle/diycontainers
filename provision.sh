#!/bin/bash

set -e

apt update && apt upgrade --yes
apt install --yes vim

#install docker
curl -sSL https://get.docker.com/ | sh

# install busybox
mkdir /tmp/playground
cp -r /vagrant/rootfs /tmp/playground/rootfs

touch /I_AM_THE_HOST
touch /tmp/playground/rootfs/I_AM_THE_CONTAINER

