#!/bin/bash

STARTDATE=$(date)
{
set -x

TYPES="base"

# Set up system to work with the Met Office Science Repository Service
TYPES="$TYPES mosrs"

# Add the EPEL repository
yum install -y epel-release

# Use the WANdisco subversion packages
cat  > /etc/yum.repos.d/WANdisco-svn.repo <<EOF
[WANdisco-svn]
name=WANdisco SVN Repo
enabled=1
baseurl=http://opensource.wandisco.com/centos/7/svn-1.8/RPMS/\$basearch/
gpgcheck=1
gpgkey=http://opensource.wandisco.com/RPM-GPG-KEY-WANdisco
EOF

# Get the latest package info and install any updates
# NB: Disabled since /vagrant fails to mount after this is run
#yum update -y

# Use dos2unix in case any files have Windows EOL characters
yum install -y dos2unix

for TYPE in $TYPES; do
  dos2unix -n /vagrant/install-$TYPE.sh /tmp/install-$TYPE.sh
  . /tmp/install-$TYPE.sh
  rm /tmp/install-$TYPE.sh
done

set +x
echo Finished provisioning at $(date) \(started at $STARTDATE\)
echo
echo Please run vagrant ssh to connect.

} |& tee -a /var/log/install.log
