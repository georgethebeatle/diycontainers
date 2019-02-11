#!/bin/bash

set -e

BUSYBOX_VERSION=1.30.0

apt update && apt upgrade --yes
apt install --yes \
  build-essential \
  wget \
  vim

wget "https://busybox.net/downloads/busybox-${BUSYBOX_VERSION}.tar.bz2"
tar -xjf busybox-1.30.0.tar.bz2

pushd "busybox-${BUSYBOX_VERSION}"
  make defconfig
  echo "CONFIG_STATIC=y" >> .config
  make && make install
  mkdir /tmp/playground
  cp -r _install /tmp/playground/rootfs
popd

