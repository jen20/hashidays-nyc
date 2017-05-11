#!/usr/bin/env bash

set -o errexit
set -o pipefail

# Create ZFS data pool and datasets
parted /dev/xvdf --script mklabel GPT
parted /dev/xvdg --script mklabel GPT

zpool create -m /srv data xvdf xvdg
zfs create -o mountpoint=/srv/consul data/consul
zfs create -o mountpoint=/srv/consulsnapshot data/consulsnapshot

zpool status
zfs list

# Create Secrets mount
mkdir /secrets
echo 'tmpfs   /secrets         tmpfs   nodev,nosuid,noexec,size=8M      0  0' \
    | sudo tee -a /etc/fstab
mount -a
