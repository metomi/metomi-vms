#!/bin/bash

STARTDATE=$(date)
{
set -x

dist=$1
release=$2
collections="base ${@:3}"

if [[ $collections =~ desktop ]]; then
  # Disable logins during installation
  echo "Installation in progress, please wait" > /etc/nologin
fi

if [[ $dist == ubuntu ]]; then
  # Address issues some hosts experience with networking (specifically, DNS latency)
  # See https://github.com/mitchellh/vagrant/issues/1172
  if [ ! $(grep single-request-reopen /etc/resolvconf/resolv.conf.d/base) ]; then
    echo "options single-request-reopen" >> /etc/resolvconf/resolv.conf.d/base && resolvconf -u
  fi
fi

if [[ $dist == redhat && $release == centos* ]]; then
  # Add the EPEL repository
  yum install -y epel-release
fi

# Use the WANdisco subversion packages
if [[ $dist == ubuntu && $release == 1404 ]]; then
  add-apt-repository 'deb http://opensource.wandisco.com/ubuntu trusty svn18'
  wget -q http://opensource.wandisco.com/wandisco-debian.gpg -O- | sudo apt-key add -
elif [[ $dist == redhat && $release == centos6 ]]; then
  cat  > /etc/yum.repos.d/WANdisco-svn.repo <<EOF
[WANdisco-svn]
name=WANdisco SVN Repo
enabled=1
baseurl=http://opensource.wandisco.com/centos/6/svn-1.8/RPMS/\$basearch/
gpgcheck=1
gpgkey=http://opensource.wandisco.com/RPM-GPG-KEY-WANdisco
EOF
elif [[ $dist == redhat && $release == centos7 ]]; then
  cat  > /etc/yum.repos.d/WANdisco-svn.repo <<EOF
[WANdisco-svn]
name=WANdisco SVN Repo
enabled=1
baseurl=http://opensource.wandisco.com/centos/7/svn-1.8/RPMS/\$basearch/
gpgcheck=1
gpgkey=http://opensource.wandisco.com/RPM-GPG-KEY-WANdisco
EOF
fi

# Get the latest package info and install any updates
if [[ $dist == ubuntu ]]; then
  export DEBIAN_FRONTEND=noninteractive  # Disable user interaction
  apt-get update -y
  apt-get upgrade -y
elif [[ $dist == redhat ]]; then
  # NB: Disabled since /vagrant fails to mount after this is run
  : #yum update -y
fi

# Use dos2unix in case any files have Windows EOL characters
if [[ $dist == ubuntu ]]; then
  apt-get install -y dos2unix
elif [[ $dist == redhat ]]; then
  yum install -y dos2unix
fi

for collection in $collections; do
  dos2unix -n /vagrant/install-$collection.sh /tmp/install-$collection.sh
  . /tmp/install-$collection.sh
  rm /tmp/install-$collection.sh
done

set +x
echo Finished provisioning at $(date) \(started at $STARTDATE\)
echo

if [[ $collections =~ desktop ]]; then
  echo Shutting down the system.
  echo Please run vagrant up to restart it.
  rm /etc/nologin
  sudo shutdown -h now
else
  echo Please run vagrant ssh to connect.
fi
} |& tee -a /var/log/install.log
