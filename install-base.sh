#### Install commonly used editors
if [[ $dist == ubuntu ]]; then
  apt-get install -q -y vim-gtk3 emacs || error
  # Set the default editor in .profile
  apt-get install -q -y featherpad || error
  echo "export EDITOR=featherpad" >>.profile
fi

#### Install FCM dependencies & configuration
if [[ $dist == ubuntu ]]; then
  apt-get install -q -y subversion firefox tkcvs tk libxml-parser-perl || error
  apt-get install -q -y m4 libconfig-inifiles-perl libdbi-perl g++ libsvn-perl || error
  apt-get install -q -y xxdiff || error
fi
# Add the fcm wrapper script
dos2unix -n /vagrant/usr/local/bin/fcm /usr/local/bin/fcm

#### Install Cylc dependencies & configuration
if [[ $dist == ubuntu ]]; then
  apt-get install -q -y at || error
  service atd start || error
  if [[ $release == 2204 ]]; then
    apt-get install -q -y python-pip graphviz graphviz-dev python2-dev sqlite3 || error
    pip2 install jinja2 || error
    pip2 install "pyOpenSSL<19.1" || error
    pip2 install pygraphviz \
      --install-option="--include-path=/usr/include/graphviz" \
      --install-option="--library-path=/usr/lib/x86_64-linu-gnu" || error
    # Provide pygtk
    wget http://archive.ubuntu.com/ubuntu/pool/universe/p/pycairo/python-cairo_1.16.2-2ubuntu2_amd64.deb
    wget http://archive.ubuntu.com/ubuntu/pool/universe/p/pygobject-2/python-gobject-2_2.28.6-14ubuntu1_amd64.deb
    wget http://archive.ubuntu.com/ubuntu/pool/universe/p/pygtk/python-gtk2_2.24.0-5.1ubuntu2_amd64.deb
    dpkg-deb -x python-gtk2_2.24.0-5.1ubuntu2_amd64.deb PackageFolder
    dpkg-deb --control python-gtk2_2.24.0-5.1ubuntu2_amd64.deb PackageFolder/DEBIAN
    sed -i 's/Depends: .*$/Depends: /' PackageFolder/DEBIAN/control
    dpkg -b PackageFolder python-gtk2_2.24.0-5.1ubuntu2_amd64-nodep.deb
    apt-get install -q -y ./python-gtk2_2.24.0-5.1ubuntu2_amd64-nodep.deb ./python-cairo_1.16.2-2ubuntu2_amd64.deb ./python-gobject-2_2.28.6-14ubuntu1_amd64.deb || error
    rm -rf PackageFolder *.deb
  fi
fi
# Add the Cylc wrapper scripts
dos2unix -n /vagrant/usr/local/bin/cylc /usr/local/bin/cylc
cd /usr/local/bin
ln -sf cylc isodatetime
if [[ $dist == ubuntu && $release == 2204 ]]; then
  ln -sf cylc gcylc
fi
# Configure additional copyable environment variables
if [[ $dist == ubuntu && $release == 2204 ]]; then
  mkdir -p /opt/metomi-site/conf
  dos2unix -n /vagrant/opt/metomi-site/conf/global.rc /opt/metomi-site/conf/global.rc
fi
mkdir -p /opt/metomi-site/etc/cylc/flow/8
dos2unix -n /vagrant/opt/metomi-site/etc/cylc/flow/8/global.cylc /opt/metomi-site/etc/cylc/flow/8/global.cylc
# Cylc Hub / UI server config
mkdir -p /opt/metomi-site/etc/cylc/uiserver/customised-interface
dos2unix -n /vagrant/opt/metomi-site/etc/cylc/uiserver/jupyter_config.py /opt/metomi-site/etc/cylc/uiserver/jupyter_config.py
dos2unix -n /vagrant/opt/metomi-site/etc/cylc/uiserver/customised-interface/login.html /opt/metomi-site/etc/cylc/uiserver/customised-interface/login.html

#### Install Rose dependencies & configuration
if [[ $dist == ubuntu ]]; then
  apt-get install -q -y gfortran || error # gfortran is used in the brief tour suite
  apt-get install -q -y pcre2-utils || error
  apt-get install -q -y lxterminal || error # rose edit is configured to use this
  apt-get install -q -y tidy || error
  apt-get install -q -y gh || error
  if [[ $release == 2204 ]]; then
    pip2 install requests || error
  fi
fi
# Add the Rose wrapper scripts
cd /usr/local/bin
ln -sf cylc rose
ln -sf cylc rosie
# Configure Rose
if [[ $dist == ubuntu && $release == 2204 ]]; then
  mkdir -p /opt/metomi-site/etc
  dos2unix -n /vagrant/opt/metomi-site/etc/rose.conf /opt/metomi-site/etc/rose.conf
fi
mkdir -p /opt/metomi-site/etc/rose
dos2unix -n /vagrant/opt/metomi-site/etc/rose/rose.conf /opt/metomi-site/etc/rose/rose.conf

#### Install latest versions of FCM, Cylc & Rose
if [[ $dist == ubuntu ]]; then
  apt-get install -q -y curl || error
  if [[ $release == 2204 ]]; then
    dos2unix -n /vagrant/usr/local/bin/install-cylc7 /usr/local/bin/install-cylc7
    /usr/local/bin/install-cylc7 --set-default || error
    dos2unix -n /vagrant/usr/local/bin/install-rose /usr/local/bin/install-rose
    /usr/local/bin/install-rose --set-default || error
  fi
fi
dos2unix -n /vagrant/usr/local/bin/install-fcm /usr/local/bin/install-fcm
/usr/local/bin/install-fcm --set-default || error
dos2unix -n /vagrant/usr/local/bin/install-cylc8 /usr/local/bin/install-cylc8
/usr/local/bin/install-cylc8 || error
# Set the default to Cylc 8
ln -sf cylc-8 /opt/cylc
# cylc review needs to be able to access cylc-run directory
chmod 755 /home/vagrant
sudo -u $(logname) mkdir -p /home/vagrant/cylc-run

#### Configure syntax highlighting & bash completion
# emacs
sudo -u $(logname) cylc get-resources syntax/cylc-mode.el /home/vagrant/.emacs.d/lisp
sudo -u $(logname) ln -sf $(rose resource syntax/rose-conf-mode.el) /home/vagrant/.emacs.d/lisp
sudo -u $(logname) dos2unix -n /vagrant/home/.emacs /home/vagrant/.emacs
# vim
sudo -u $(logname) mkdir -p /home/vagrant/.vim/pack/vendor/start
sudo -u $(logname) git clone https://github.com/cylc/cylc.vim.git /home/vagrant/.vim/pack/vendor/start/cylc.vim.git
ln -s $(rose resource syntax/rose-conf.vim) /home/vagrant/.vim/syntax
sudo -u $(logname) dos2unix -n /vagrant/home/.vimrc /home/vagrant/.vimrc
# bash
sudo -u $(logname) cylc get-resources cylc-completion.bash /home/vagrant/.bash
echo "[[ \$- =~ i && -f /home/vagrant/.bash/cylc-completion.bash ]] && . /home/vagrant/.bash/cylc-completion.bash" >>/home/vagrant/.bashrc

if [[ $dist == ubuntu && $release == 2204 ]]; then
  #### Configure cylc review & rosie web services (with a local rosie repository)
  apt-get install -q -y apache2 libapache2-mod-svn || error
  apt-get install -q -y apache2-dev apache2-utils || error
  pip2 install cherrypy sqlalchemy || error
  curl -L -s -S https://codeload.github.com/GrahamDumpleton/mod_wsgi/tar.gz/4.9.3 | tar -xz
  cd mod_wsgi-4.9.3
  ./configure --with-python=/usr/bin/python2
  make
  make install
  cd ..
  rm -r mod_wsgi-4.9.3
  echo "LoadModule wsgi_module /usr/lib/apache2/modules/mod_wsgi.so" > /etc/apache2/mods-enabled/wsgi.conf
  # Configure apache
  mkdir -p /opt/metomi-site/etc/httpd
  ln -sf /opt /var/www/html
  dos2unix -n /vagrant/var/www/html/index.html /var/www/html/index.html
  dos2unix -n /vagrant/opt/metomi-site/etc/httpd/rosie-wsgi.conf /opt/metomi-site/etc/httpd/rosie-wsgi.conf
  ln -sf /opt/metomi-site/etc/httpd/rosie-wsgi.conf /etc/apache2/conf-enabled/rosie-wsgi.conf
  dos2unix -n /vagrant/opt/metomi-site/etc/httpd/svn.conf /opt/metomi-site/etc/httpd/svn.conf
  ln -sf /opt/metomi-site/etc/httpd/svn.conf /etc/apache2/conf-enabled/svn.conf
  service apache2 restart || error
  # Setup the rosie repository
  mkdir /srv/svn
  sudo chown www-data /srv/svn
  sudo -u www-data svnadmin create /srv/svn/roses-tmp
  htpasswd -b -c /srv/svn/auth.htpasswd vagrant vagrant || error
  # Cache the password
  sudo -u $(logname) mkdir -p /home/vagrant/.subversion/auth/svn.simple
  realm="<http://localhost:80> Subversion repository"
  cache_id=$(echo -n "${realm}" | md5sum | cut -f1 -d " ")
  sudo -u $(logname) bash -c "cat >/home/vagrant/.subversion/auth/svn.simple/${cache_id}" <<EOF
K 8
passtype
V 6
simple
K 8
password
V 7
vagrant
K 15
svn:realmstring
V ${#realm}
${realm}
K 8
username
V 7
vagrant
END
EOF
  cd /home/vagrant
  sudo -H -u $(logname) bash -c 'svn co -q http://localhost/svn/roses-tmp'
  sudo -H -u $(logname) bash -c 'svn ps fcm:layout -F - roses-tmp' <<EOF
depth-project = 5
depth-branch = 1
depth-tag = 1
dir-trunk = trunk
dir-branch =
dir-tag =
level-owner-branch =
level-owner-tag =
template-branch =
template-tag =
EOF
  sudo -H -u $(logname) bash -c 'svn ci -m "fcm:layout: defined." roses-tmp'
  rm -rf roses-tmp
  mkdir -p /opt/metomi-site/etc/hooks
  dos2unix -n /vagrant/opt/metomi-site/etc/hooks/pre-commit /opt/metomi-site/etc/hooks/pre-commit
  ln -sf /opt/metomi-site/etc/hooks/pre-commit /srv/svn/roses-tmp/hooks/pre-commit
  dos2unix -n /vagrant/opt/metomi-site/etc/hooks/post-commit /opt/metomi-site/etc/hooks/post-commit
  ln -sf /opt/metomi-site/etc/hooks/post-commit /srv/svn/roses-tmp/hooks/post-commit
  sudo -u www-data /opt/rose/sbin/rosa db-create || error

else
  #### Configure JupyterHub
  dos2unix -n /vagrant/etc/systemd/system/jupyterhub.service /etc/systemd/system/jupyterhub.service
  systemctl daemon-reload
  systemctl enable jupyterhub
  systemctl start jupyterhub
fi

#### Miscellaneous utilities
dos2unix -n /vagrant/usr/local/bin/install-iris /usr/local/bin/install-iris
dos2unix -n /vagrant/usr/local/bin/install-jules-benchmark-data /usr/local/bin/install-jules-benchmark-data
dos2unix -n /vagrant/usr/local/bin/install-jules-extras /usr/local/bin/install-jules-extras
dos2unix -n /vagrant/usr/local/bin/install-jules-gswp2-data /usr/local/bin/install-jules-gswp2-data
dos2unix -n /vagrant/usr/local/bin/install-nvidia /usr/local/bin/install-nvidia
dos2unix -n /vagrant/usr/local/bin/install-ukca-data /usr/local/bin/install-ukca-data
dos2unix -n /vagrant/usr/local/bin/install-um-data /usr/local/bin/install-um-data
dos2unix -n /vagrant/usr/local/bin/install-um-extras /usr/local/bin/install-um-extras
dos2unix -n /vagrant/usr/local/bin/um-setup /usr/local/bin/um-setup
