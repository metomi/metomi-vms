#### Install the LXDE desktop
if [[ $dist == ubuntu ]]; then
  if [[ $release == 16* ]]; then
    apt-get install -q -y xorg lxdm lxde
  else
    apt-get install -q -y lightdm-gtk-greeter xorg lxde
  fi
  if [[ $release == 16* ]]; then
    apt-get install -q -y lxsession-logout
  fi
  apt-get remove -q -y --auto-remove xscreensaver xscreensaver-data gnome-keyring
  # Set language
  apt-get install -q -y language-pack-en
  update-locale LANG=en_GB.utf8
  # Set UK keyboard
  perl -pi -e 's/XKBLAYOUT="us"/XKBLAYOUT="gb"/;' /etc/default/keyboard
  if [[ $release == 1404 ]]; then
    # Move panel to top (works better when resizing the screen)
    perl -pi -e 's/edge=bottom/edge=top/;' /usr/share/lxpanel/profile/LXDE/panels/panel
  fi
  # Create a desktop shortcut
  sudo -u vagrant mkdir -p /home/vagrant/Desktop
  sudo -u vagrant cp /usr/share/applications/lxterminal.desktop /home/vagrant/Desktop
  if [[ $release == 1404 ]]; then
    # Allow shutdown to work (https://tracker.zentyal.org/issues/360)
    echo "session required pam_systemd.so" >> /etc/pam.d/lxdm
  fi
elif [[ $dist == redhat ]]; then
  yum install -y @lxde-desktop @base-x
  yum remove -y gnome-keyring xscreensaver-base
  systemctl set-default graphical.target
  # Set UK keyboard
  localectl set-x11-keymap gb
fi
# Enable auto login
perl -pi -e 's/^.*autologin=.*$/autologin=vagrant/;' /etc/lxdm/lxdm.conf
# Open a terminal on startup
sudo -u vagrant mkdir -p /home/vagrant/.config/autostart
sudo -u vagrant cp /usr/share/applications/lxterminal.desktop /home/vagrant/.config/autostart
# Prevent prompt from clipit on first use
if [[ $dist == redhat || ($dist == ubuntu && $release == 16*) ]]; then
  sudo -u vagrant mkdir -p /home/vagrant/.config/clipit
  sudo -u vagrant bash -c 'echo "[rc]" >/home/vagrant/.config/clipit/clipitrc'
  sudo -u vagrant bash -c 'echo "offline_mode=false" >>/home/vagrant/.config/clipit/clipitrc'
fi
