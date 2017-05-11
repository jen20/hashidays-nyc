#!/usr/bin/env bash

set -o errexit
set -o pipefail

# Remove existing MOTD
rm -rf /etc/update-motd.d/*

# Update metadata and upgrade packages in the base  image
export DEBIAN_FRONTEND=noninteractive
apt-get install -y hashistack-motd

# Configure bash on interactive sessions to show MOTD
cp /etc/skel/bashrc .bashrc
sed -i 's/session    optional   pam_motd.so motd=\/run\/motd.dynamic/#session    optional   pam_motd.so motd=\/run\/motd.dynamic/' /etc/pam.d/login
sed -i 's/session    optional   pam_motd.so noupdate/#session    optional   pam_motd.so noupdate/' /etc/pam.d/login

# Write configuration for MOTD
mkdir -p /etc/hashistack-motd
echo "${MOTD_ENVIRONMENT}" > /etc/hashistack-motd/environment
echo "${MOTD_REGION}" > /etc/hashistack-motd/region
