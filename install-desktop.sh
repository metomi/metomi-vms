#### Install the LXDE desktop
sudo -u $(logname) mkdir -p /home/vagrant/Desktop
if [[ $dist == ubuntu ]]; then
  apt-get install -q -y lxde xinput || error
  apt-get remove -q -y --auto-remove --purge xscreensaver xscreensaver-data gnome-keyring || error
  apt-get remove -q -y --auto-remove --purge gnome-screensaver lxlock light-locker network-manager-gnome gnome-online-accounts || error
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
fi
# Enable auto login
if [[ $dist == ubuntu ]]; then
  echo "[SeatDefaults]" >> /usr/share/lightdm/lightdm.conf.d/lxde.conf
  echo "user-session=LXDE" >> /usr/share/lightdm/lightdm.conf.d/lxde.conf
  echo "autologin-user=vagrant" >> /usr/share/lightdm/lightdm.conf.d/lxde.conf
  echo "autologin-user-timeout=0" >> /usr/share/lightdm/lightdm.conf.d/lxde.conf
fi
# Create a desktop shortcut for local browser (docs / JupyterHub)
sudo -u $(logname) dos2unix -n /vagrant/home/Desktop/browser.desktop /home/vagrant/Desktop/browser.desktop
# Open a terminal on startup
sudo -u $(logname) mkdir -p /home/vagrant/.config/autostart
sudo -u $(logname) cp /usr/share/applications/lxterminal.desktop /home/vagrant/.config/autostart
# Prevent prompt from clipit on first use
sudo -u $(logname) mkdir -p /home/vagrant/.config/clipit
sudo -u $(logname) bash -c 'echo "[rc]" >/home/vagrant/.config/clipit/clipitrc'
sudo -u $(logname) bash -c 'echo "offline_mode=false" >>/home/vagrant/.config/clipit/clipitrc'
# Setup desktop background colour
if [[ $dist == ubuntu ]]; then
  sudo -u $(logname) mkdir -p /home/vagrant/.config/pcmanfm/LXDE
  sudo -u $(logname) bash -c 'echo "[*]" >/home/vagrant/.config/pcmanfm/LXDE/desktop-items-0.conf'
  sudo -u $(logname) bash -c 'echo "desktop_bg=#2f4266" >>/home/vagrant/.config/pcmanfm/LXDE/desktop-items-0.conf'
  sudo -u $(logname) mkdir -p /home/vagrant/.config/libfm
  sudo -u $(logname) bash -c 'echo "[config]" >/home/vagrant/.config/libfm/libfm.conf'
  sudo -u $(logname) bash -c 'echo "quick_exec=1" >>/home/vagrant/.config/libfm/libfm.conf'
fi
