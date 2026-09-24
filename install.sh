#!/bin/bash

STARTDATE=$(date +"%Y-%m-%dT%H%M")
ERROR_COUNT=0
error() {
  ((ERROR_COUNT++))
  echo "[ERROR] $@"
}

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
  # Install Firefox using DEB package rather than snap to avoid timeout issues
  install -d -m 0755 /etc/apt/keyrings
  wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null || error
  tee /etc/apt/sources.list.d/mozilla.sources > /dev/null << EOF
Types: deb
URIs: https://packages.mozilla.org/apt
Suites: mozilla
Components: main
Signed-By: /etc/apt/keyrings/packages.mozilla.org.asc
EOF
  tee /etc/apt/preferences.d/mozilla > /dev/null << EOF
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
EOF
  # Get the latest package info and install any updates
  export DEBIAN_FRONTEND=noninteractive  # Disable user interaction
  apt-get -yq update || error
  apt-get -yq -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade || error
fi

# Use dos2unix in case any files have Windows EOL characters
if [[ $dist == ubuntu ]]; then
  apt-get -yq install dos2unix || error
fi

for collection in $collections; do
  if [[ ! $collection == skip-shutdown ]]; then
    echo $(date +"%Y-%m-%dT%H%M") - Installing $collection collection ...
    dos2unix -n /vagrant/install-$collection.sh /tmp/install-$collection.sh
    . /tmp/install-$collection.sh
    rm /tmp/install-$collection.sh
  fi
done

set +x
echo Finished provisioning at $(date +"%Y-%m-%dT%H%M") \(started at $STARTDATE\)
echo

if [[ $ERROR_COUNT != "0" ]]; then
  echo "[ERROR] $ERROR_COUNT errors occurred during installation"
else
  echo "[INFO] No errors detected"
fi

rm -f /etc/nologin
if [[ $collections =~ desktop && ! $collections =~ skip-shutdown ]]; then
  echo Shutting down the system.
  echo Please run vagrant up to restart it.
  sudo shutdown -h now
else
  echo Please run vagrant ssh to connect.
fi

} |& tee -a /var/log/install.log
