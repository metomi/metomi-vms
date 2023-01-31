# Changes necessary for running with libvirt using generic/ubuntu1804 box
if [[ $dist == ubuntu ]]; then
  if [[ $release == 1804 ]]; then
    # change setting in sshd_config to allow X11 connections
    apt-get install -q -y sed || error
    sed -i 's/#AddressFamily any/AddressFamily inet/g' /etc/ssh/sshd_config || error
    systemctl restart sshd || error
    # delete offending line in hosts that prevents cylc from working
    sed -i '/127.0.0.1 ubuntu1804.localdomain/d' /etc/hosts || error
  fi
fi
