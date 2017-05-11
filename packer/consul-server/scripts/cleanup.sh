#!/usr/bin/env bash

set -o errexit
set -o pipefail

rm -rf /var/lib/cloud/instances/*
rm -f /root/.ssh/authorized_keys
rm -f /home/ops/.ssh/authorized_keys
rm -f /home/ops/.bash_history
