#### Install the LXDE desktop
apt-get install -y lightdm-gtk-greeter xorg lxde
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
# Allow shutdown to work (https://tracker.zentyal.org/issues/360)
echo "session required pam_systemd.so" >> /etc/pam.d/lxdm
