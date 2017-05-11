#!/usr/bin/env bash

set -o errexit
set -o pipefail

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y consul-bootstrap-aws journald-cloudwatch-logs

systemctl enable consul.service
systemctl enable consul-online.service
systemctl enable consul-online.target
systemctl enable journald-cloudwatch-logs.service
