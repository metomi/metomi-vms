#### Install the LXDE desktop
sudo -u $(logname) mkdir -p /home/vagrant/Desktop
if [[ $dist == ubuntu ]]; then
  if [[ $release == 1604 ]]; then
    apt-get install -q -y xorg lxdm lxde lxsession-logout || error
  else
    apt-get install -q -y lxde xinput || error
  fi
  apt-get remove -q -y --auto-remove --purge xscreensaver xscreensaver-data gnome-keyring || error
  if [[ $release != 1604 ]]; then
    apt-get remove -q -y --auto-remove --purge gnome-screensaver lxlock light-locker network-manager-gnome gnome-online-accounts || error
  fi
  # Set language
  update-locale LANG=en_GB.utf8 || {
    # have an error updating the locale - need to generate first
    locale-gen "en_GB.utf8" || error
    dpkg-reconfigure --frontend=noninteractive locales || error
    update-locale LANG=en_GB.utf8 || error
  }
  # Set UK keyboard
  perl -pi -e 's/XKBLAYOUT="us"/XKBLAYOUT="gb"/;' /etc/default/keyboard
  # Create a desktop shortcut
  sudo -u $(logname) cp /usr/share/applications/lxterminal.desktop /home/vagrant/Desktop
elif [[ $dist == redhat ]]; then
  yum install -y @lxde-desktop @base-x || error
  yum remove -y gnome-keyring xscreensaver-base || error
  systemctl set-default graphical.target || error
  # Set UK keyboard
  localectl set-x11-keymap gb || error
fi
# Enable auto login
if [[ $dist == ubuntu && $release != 1604 ]]; then
  echo "[SeatDefaults]" >> /usr/share/lightdm/lightdm.conf.d/lxde.conf
  echo "user-session=LXDE" >> /usr/share/lightdm/lightdm.conf.d/lxde.conf
  echo "autologin-user=vagrant" >> /usr/share/lightdm/lightdm.conf.d/lxde.conf
  echo "autologin-user-timeout=0" >> /usr/share/lightdm/lightdm.conf.d/lxde.conf
else
  perl -pi -e 's/^.*autologin=.*$/autologin=vagrant/;' /etc/lxdm/lxdm.conf
fi
# Create a desktop shortcut to the local documentation
sudo -u $(logname) dos2unix -n /vagrant/home/Desktop/docs.desktop /home/vagrant/Desktop/docs.desktop
# Open a terminal on startup
sudo -u $(logname) mkdir -p /home/vagrant/.config/autostart
sudo -u $(logname) cp /usr/share/applications/lxterminal.desktop /home/vagrant/.config/autostart
# Configure middle button emulation
if [[ $dist == ubuntu && $release == 1604 ]]; then
  sudo -u $(logname) bash -c 'echo "[Desktop Entry]" >/home/vagrant/.config/autostart/xinput.desktop'
  sudo -u $(logname) bash -c 'echo "Exec=xinput set-prop 11 \"Evdev Middle Button Emulation\" 1" >>/home/vagrant/.config/autostart/xinput.desktop'
elif [[ ($dist == ubuntu && $release == 1804) || ($dist == redhat && $release == fedora*) ]]; then
  sudo -u $(logname) bash -c 'echo "[Desktop Entry]" >/home/vagrant/.config/autostart/xinput.desktop'
  sudo -u $(logname) bash -c 'echo "Exec=xinput set-prop 11 \"libinput Middle Emulation Enabled\" 1" >>/home/vagrant/.config/autostart/xinput.desktop'
fi
# Prevent prompt from clipit on first use
sudo -u $(logname) mkdir -p /home/vagrant/.config/clipit
sudo -u $(logname) bash -c 'echo "[rc]" >/home/vagrant/.config/clipit/clipitrc'
sudo -u $(logname) bash -c 'echo "offline_mode=false" >>/home/vagrant/.config/clipit/clipitrc'
# Setup desktop background colour
if [[ $dist == ubuntu && $release != 1604 ]]; then
  sudo -u $(logname) mkdir -p /home/vagrant/.config/pcmanfm/LXDE
  sudo -u $(logname) bash -c 'echo "[*]" >/home/vagrant/.config/pcmanfm/LXDE/desktop-items-0.conf'
  sudo -u $(logname) bash -c 'echo "desktop_bg=#2f4266" >>/home/vagrant/.config/pcmanfm/LXDE/desktop-items-0.conf'
fi
if [[ $dist == ubuntu && $release == 2204 ]]; then
  sudo -u $(logname) mkdir -p /home/vagrant/.config/libfm
  sudo -u $(logname) bash -c 'echo "[config]" >/home/vagrant/.config/libfm/libfm.conf'
  sudo -u $(logname) bash -c 'echo "quick_exec=1" >>/home/vagrant/.config/libfm/libfm.conf'
fi
