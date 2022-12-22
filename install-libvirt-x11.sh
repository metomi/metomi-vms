#### change setting in sshd_config to allow X11 connections
if [[ $dist == ubuntu ]]; then
  if [[ $release == 1804 ]]; then
    apt-get install -q -y sed || error
    sed -i 's/#AddressFamily any/AddressFamily inet/g' /etc/ssh/sshd_config || error
    systemctl restart sshd || error
  fi
fi
