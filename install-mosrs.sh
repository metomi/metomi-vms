#### Install and configure gpg-agent
if [[ $dist == ubuntu && ($release == 1404 || $release == 1510) ]]; then
  apt-get install -q -y gnupg-agent
elif [[ $dist == ubuntu || ($dist == redhat && $release == fedora*) ]]; then
  if [[ $dist == ubuntu ]]; then
    apt-get install -q -y libgpg-error-dev libgcrypt20-dev libassuan-dev libksba-dev libpth-dev
  else
    yum install -y zlib-devel libgpg-error-devel libgcrypt-devel libassuan-devel libksba-devel
  fi
  curl -L -s -S https://www.gnupg.org/ftp/gcrypt/gnupg/gnupg-2.0.30.tar.bz2 | tar -xj
  cd gnupg-2.0.30
  ./configure
  make
  make install
  cd ..
  rm -r gnupg-2.0.30
fi
# Add script that caches the user's Science Repository Service password for the session
dos2unix -n /vagrant/usr/local/bin/mosrs-cache-password /usr/local/bin/mosrs-cache-password
# Add script to start gpg-agent and cache the password when needed and source it in .bashrc
dos2unix -n /vagrant/usr/local/bin/mosrs-setup-gpg-agent /usr/local/bin/mosrs-setup-gpg-agent
echo ". /usr/local/bin/mosrs-setup-gpg-agent" >>/home/vagrant/.bashrc
# Start & stop gpg-agent to avoid errors on first use
sudo -H -u vagrant /usr/bin/gpg-agent --daemon
sudo -H -u vagrant /usr/bin/pkill gpg-agent
# Add script to install Rose meta data
dos2unix -n /vagrant/usr/local/bin/install-rose-meta /usr/local/bin/install-rose-meta

#### Configure FCM
mkdir -p /etc/subversion
# Set up subversion to not use plaintext passwords for Met Office Science Repository Service
dos2unix -n /vagrant/etc/subversion/servers /etc/subversion/servers
# Set up subversion to use gpg-agent as the password store
dos2unix -n /vagrant/etc/subversion/config /etc/subversion/config
# Set up FCM keywords
dos2unix -n /vagrant/opt/metomi-site/etc/fcm/keyword.cfg /opt/metomi-site/etc/fcm/keyword.cfg
ln -sf /opt/metomi-site/etc/fcm/keyword.cfg /opt/fcm-$FCM_VERSION/etc/fcm/keyword.cfg
