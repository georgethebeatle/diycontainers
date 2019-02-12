#!/bin/bash

set -e

BUSYBOX_VERSION=1.30.0

apt update && apt upgrade --yes
apt install --yes \
  build-essential \
  wget \
  vim

#install docker
curl -sSL https://get.docker.com/ | sh

# install busybox
wget "https://busybox.net/downloads/busybox-${BUSYBOX_VERSION}.tar.bz2"
tar -xjf busybox-1.30.0.tar.bz2

pushd "busybox-${BUSYBOX_VERSION}"
  cp /vagrant/.config .config
  make && make install
  mkdir /tmp/playground
  cp -r _install /tmp/playground/rootfs
popd

touch /I_AM_THE_HOST
touch /tmp/playground/rootfs/I_AM_THE_CONTAINER

