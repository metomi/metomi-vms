if [[ $dist == ubuntu ]]; then
  #### Install the LXDE desktop
  apt-get install -y lightdm-gtk-greeter xorg lxde
  if [[ $release == 1504 ]]; then
    apt-get install -y lxsession-logout
  fi
  apt-get remove -y xscreensaver xscreensaver-data gnome-keyring
  # Set language
  apt-get install -y language-pack-en
  update-locale LANG=en_GB.utf8
  # Set UK keyboard
  perl -pi -e 's/XKBLAYOUT="us"/XKBLAYOUT="gb"/;' /etc/default/keyboard
  # Enable auto login
  perl -pi -e 's/^.*autologin=.*$/autologin=vagrant/;' /etc/lxdm/lxdm.conf
  # Move panel to top (works better when resizing the screen)
  perl -pi -e 's/edge=bottom/edge=top/;' /usr/share/lxpanel/profile/LXDE/panels/panel
  # Open a terminal on startup
  sudo -u vagrant mkdir -p /home/vagrant/.config/autostart
  sudo -u vagrant cp /usr/share/applications/lxterminal.desktop /home/vagrant/.config/autostart
  if [[ $release == 1404 ]]; then
    # Allow shutdown to work (https://tracker.zentyal.org/issues/360)
    echo "session required pam_systemd.so" >> /etc/pam.d/lxdm
  elif [[ $release == 1504 ]]; then
    # Fix lxdm bug
    # https://launchpad.net/ubuntu/+source/lxdm/0.5.1-1
    # https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=781949
    perl -pi -e 's/BusName=/#BusName=/;' /lib/systemd/system/lxdm.service
  fi
fi
