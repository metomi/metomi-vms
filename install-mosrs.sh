#### Install and configure gpg-agent
# Add script that caches the user's Science Repository Service password for the session
dos2unix -n /vagrant/usr/local/bin/mosrs-cache-password /usr/local/bin/mosrs-cache-password
# Add script to start gpg-agent and cache the password when needed and source it in .bashrc
dos2unix -n /vagrant/usr/local/bin/mosrs-setup-gpg-agent /usr/local/bin/mosrs-setup-gpg-agent
echo ". /usr/local/bin/mosrs-setup-gpg-agent" >>/home/vagrant/.bashrc
# Add script to install Rose meta data
dos2unix -n /vagrant/usr/local/bin/install-rose-meta /usr/local/bin/install-rose-meta
# Set gpg-agent options (required when gpg-agent started automatically)
sudo -u $(logname) mkdir -p /home/vagrant/.gnupg
sudo -u $(logname) bash -c 'echo "allow-preset-passphrase" >/home/vagrant/.gnupg/gpg-agent.conf'
sudo -u $(logname) bash -c 'echo "batch" >>/home/vagrant/.gnupg/gpg-agent.conf'
sudo -u $(logname) bash -c 'echo "max-cache-ttl 43200" >>/home/vagrant/.gnupg/gpg-agent.conf'

#### Configure FCM
mkdir -p /etc/subversion
# Set up subversion to not use plaintext passwords for Met Office Science Repository Service
dos2unix -n /vagrant/etc/subversion/servers /etc/subversion/servers
# Set up subversion to use gpg-agent as the password store
dos2unix -n /vagrant/etc/subversion/config /etc/subversion/config
# Set up FCM keywords
mkdir -p /opt/metomi-site/etc/fcm
dos2unix -n /vagrant/opt/metomi-site/etc/fcm/keyword.cfg /opt/metomi-site/etc/fcm/keyword.cfg
ln -sf /opt/metomi-site/etc/fcm/keyword.cfg /opt/fcm/etc/fcm/keyword.cfg
