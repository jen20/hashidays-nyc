#!/usr/bin/env bash

set -o errexit
set -o pipefail

# Add repository for local packages if one is configured
if [ ! -z "${APT_REPO_URL}" ] ; then
    echo "deb ${APT_REPO_URL} xenial main" | tee /etc/apt/sources.list.d/ops.list
    wget -qO- "${APT_REPO_URL}/apt.key" | apt-key add -
fi

# Update metadata and upgrade packages in the base  image
export DEBIAN_FRONTEND=noninteractive
echo "cloud-init hold" | dpkg --set-selections
apt-get update
apt-get upgrade -y

# Install sshd configuration package if one is configured
if [ ! -z  "${SSHD_CONFIG_PACKAGE}" ] ; then
    apt-get install -o Dpkg::Options::="--force-confnew" -y "${SSHD_CONFIG_PACKAGE}"
fi

# Install CA roots package if one is configured
if [ ! -z  "${CA_ROOTS_PACKAGE}" ] ; then
    apt-get install -y "${CA_ROOTS_PACKAGE}"
fi

# Install utilities which should be on every instance
apt-get install -y \
    awscli \
    curl \
    silversearcher-ag \
    sysstat \
    tree \
    vim
