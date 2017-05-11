#!/usr/bin/env bash

set -o errexit
set -o pipefail

mv /tmp/cloud.cfg /etc/cloud/cloud.cfg
chown root:root /etc/cloud/cloud.cfg
