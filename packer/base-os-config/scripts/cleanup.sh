#!/usr/bin/env bash

set -o errexit
set -o pipefail

# Disable apt updates which interfere with startup
sudo mkdir /etc/systemd/system/apt-daily.timer.d
echo '[Timer]' | sudo tee /etc/systemd/system/apt-daily.timer.d/apt-daily.timer.conf
echo 'Persistent=false' | sudo tee -a /etc/systemd/system/apt-daily.timer.d/apt-daily.timer.conf

# Clean up Cloud Init and SSH Keys
sudo rm -rf /var/lib/cloud/instances/*
sudo rm -f /root/.ssh/authorized_keys
sudo rm -f /home/ops/.ssh/authorized_keys

# Ensure there is an entry for localhost pointing to loopback
sudo sed -i 's/127.0.0.1[ \\t]*localhost.*$/127.0.0.1 localhost/' /etc/hosts

# Remove bash history
rm -f /home/ops/.bash_history
