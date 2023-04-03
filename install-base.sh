if [[ $dist == redhat ]]; then
  #### Disable SELinux to keep things simple
  setenforce 0 || error
  perl -pi -e 's/^SELINUX=enforcing/SELINUX=disabled/;' /etc/selinux/config
fi

if [[ $dist == redhat && $release != centos7 ]]; then
  #### Enable X applications to open the display
  yum install -y xauth || error
fi

#### Install commonly used editors
if [[ $dist == ubuntu ]]; then
  apt-get install -q -y vim-gtk emacs || error
  # Set the default editor in .profile
  if [[ $release != 2204 ]]; then
    apt-get install -q -y leafpad || error
    echo "export EDITOR=leafpad" >>.profile
  else
    apt-get install -q -y featherpad || error
    echo "export EDITOR=featherpad" >>.profile
  fi
elif [[ $dist == redhat ]]; then
  yum install -y gvim emacs || error
  # Set the default editor in .bash_profile
  if [[ $release == fedora* ]]; then
    yum install -y leafpad || error
    echo "export EDITOR=leafpad" >>.bash_profile
  else
    echo "export EDITOR=emacs" >>.bash_profile
  fi
fi

#### Install FCM dependencies & configuration
if [[ $dist == ubuntu ]]; then
  apt-get install -q -y subversion firefox tkcvs tk libxml-parser-perl || error
  apt-get install -q -y m4 libconfig-inifiles-perl libdbi-perl g++ libsvn-perl || error
  apt-get install -q -y xxdiff || error
elif [[ $dist == redhat ]]; then
  yum install -y subversion firefox perl-core perl-XML-Parser || error
  if [[ $release == centos8 ]]; then
    dnf config-manager --set-enabled powertools
  fi
  yum install -y perl-Config-IniFiles subversion-perl || error
  yum install -y gcc-c++ || error  # used by fcm test-battery
  if [[ $release == fedora* ]]; then
    yum install -y m4 perl-DBI || error
    yum install -y tkcvs xxdiff || error
  elif [[ $release == centos7 ]]; then
    yum install -y tkcvs kdiff3 || error
  else
    yum install -y perl-DBI || error
    yum install -y kdiff3 || error
  fi
fi
# Add the fcm wrapper script
dos2unix -n /vagrant/usr/local/bin/fcm /usr/local/bin/fcm
# Configure FCM diff and merge viewers
if [[ $dist == redhat && $release != fedora* ]]; then
  mkdir -p /opt/metomi-site/etc/fcm
  dos2unix -n /vagrant/opt/metomi-site/etc/fcm/external.cfg /opt/metomi-site/etc/fcm/external.cfg
fi

#### Install Cylc dependencies & configuration
if [[ $dist == ubuntu ]]; then
  apt-get install -q -y at python-pip  || error
  service atd start || error
  if [[ $release != 2204 ]]; then
    apt-get install -q -y graphviz python-jinja2 python-pygraphviz python-gtk2 sqlite3 || error
  else
    apt-get install -q -y graphviz graphviz-dev python2-dev sqlite3 || error
    pip2 install jinja2 || error
    pip2 install "pyOpenSSL<19.1" || error
    # Provide pygtk via Conda
    dos2unix -n /vagrant/usr/local/bin/install-pygtk /usr/local/bin/install-pygtk
    sudo -u $(logname) /usr/local/bin/install-pygtk || error
  fi
  apt-get install -q -y pep8 || error # used by test-battery
  if [[ $release != 1604 ]]; then
    : # Rose docs build no longer working - disable for the moment
    #apt-get install -q -y imagemagick || error
  fi
elif [[ $dist == redhat ]]; then
  yum install -y graphviz at lsof || error
  service atd start || error
  if [[ $release == fedora* ]]; then
    yum install -y redhat-rpm-config sqlite || error
    yum install -y ImageMagick || error
  elif [[ $release == centos8 ]]; then
    yum install -y sqlite || error
  fi
  if [[ $release == centos8 ]]; then
    yum install -y python2-pip python2-jinja2 || error
  else
    yum install -y python-pip python-pep8 python-jinja2 || error
  fi
  yum install -y pygtk2 || error
  if [[ $release == centos7 ]]; then
    yum install -y python2-pygraphviz pyOpenSSL || error
  elif [[ $release == centos8 ]]; then
    yum install -y graphviz-devel python2-devel || error
    pip2 install pygraphviz || error
    pip2 install "pyOpenSSL<19.1" || error
  else
    yum install -y python-pygraphviz pyOpenSSL || error
  fi
  # Ensure "hostname -f" returns the fully qualified name
  perl -pi -e 's/localhost localhost.localdomain/localhost.localdomain localhost/;' /etc/hosts
fi
# Add the Cylc wrapper scripts
dos2unix -n /vagrant/usr/local/bin/cylc /usr/local/bin/cylc
cd /usr/local/bin
ln -sf cylc gcylc
# Configure additional copyable environment variables
mkdir -p /opt/metomi-site/conf
dos2unix -n /vagrant/opt/metomi-site/conf/global.rc /opt/metomi-site/conf/global.rc

#### Install Rose dependencies & configuration
if [[ $dist == ubuntu ]]; then
  apt-get install -q -y gfortran || error # gfortran is used in the brief tour suite
  apt-get install -q -y pcregrep || error
  apt-get install -q -y lxterminal || error # rose edit is configured to use this
  apt-get install -q -y tidy || error
  if [[ $release != 2204 ]]; then
    apt-get install -q -y python-requests || error
    apt-get install -q -y python-virtualenv || error # needed by rose make-docs
    pip install mock pytest-tap || error # used by test-battery
  else
    pip2 install requests || error
    pip2 install mock pytest-tap || error # used by test-battery
  fi
elif [[ $dist == redhat ]]; then
  yum install -y rsync xterm || error
  yum install -y gcc-gfortran || error # gfortran is used in the brief tour suite
  if [[ $release == centos8 ]]; then
    yum install -y python2-requests || error
    pip2 install mock pytest-tap || error # used by test-battery
  else
    yum install -y python-requests || error
    yum install -y pcre-tools || error
    pip install mock pytest-tap || error # used by test-battery
  fi
  if [[ $release == fedora* ]]; then
    yum install -y python2-virtualenv || error # needed by rose make-docs
  fi
fi
# Add the Rose wrapper scripts
dos2unix -n /vagrant/usr/local/bin/rose /usr/local/bin/rose
cd /usr/local/bin
ln -sf rose rosie
# Configure Rose
mkdir -p /opt/metomi-site/etc
if [[ $dist == ubuntu ]]; then
  dos2unix -n /vagrant/opt/metomi-site/etc/rose.conf /opt/metomi-site/etc/rose.conf
elif [[ $dist == redhat ]]; then
  dos2unix -n /vagrant/opt/metomi-site/etc/rose.conf.redhat /opt/metomi-site/etc/rose.conf
fi

#### Install latest versions of FCM, Cylc & Rose
if [[ $dist == ubuntu ]]; then
  # Ensure curl is installed
  apt-get install -q -y curl || error
fi
dos2unix -n /vagrant/usr/local/bin/install-fcm /usr/local/bin/install-fcm
dos2unix -n /vagrant/usr/local/bin/install-cylc7 /usr/local/bin/install-cylc7
dos2unix -n /vagrant/usr/local/bin/install-rose /usr/local/bin/install-rose
/usr/local/bin/install-fcm --set-default || error
/usr/local/bin/install-cylc7 --set-default --make-docs || error
/usr/local/bin/install-rose --set-default --make-docs || error

#### Configure syntax highlighting & bash completion
sudo -u $(logname) mkdir -p /home/vagrant/.local/share/gtksourceview-3.0/language-specs/
sudo -u $(logname) ln -sf /opt/cylc/conf/cylc.lang /home/vagrant/.local/share/gtksourceview-3.0/language-specs
sudo -u $(logname) ln -sf /opt/rose/etc/rose-conf.lang /home/vagrant/.local/share/gtksourceview-3.0/language-specs
sudo -u $(logname) mkdir -p /home/vagrant/.vim/syntax
sudo -u $(logname) ln -sf /opt/cylc/conf/cylc.vim /home/vagrant/.vim/syntax
sudo -u $(logname) ln -sf /opt/rose/etc/rose-conf.vim /home/vagrant/.vim/syntax
sudo -u $(logname) dos2unix -n /vagrant/home/.vimrc /home/vagrant/.vimrc
sudo -u $(logname) mkdir -p /home/vagrant/.emacs.d/lisp
sudo -u $(logname) ln -sf /opt/cylc/conf/cylc-mode.el /home/vagrant/.emacs.d/lisp
sudo -u $(logname) ln -sf /opt/rose/etc/rose-conf-mode.el /home/vagrant/.emacs.d/lisp
sudo -u $(logname) dos2unix -n /vagrant/home/.emacs /home/vagrant/.emacs
if [[ $dist == redhat ]]; then
  echo '[[ "$-" != *i* ]] && return # Stop here if not running interactively' >>/home/vagrant/.bashrc
fi
echo "[[ -f /opt/rose/etc/rose-bash-completion ]] && . /opt/rose/etc/rose-bash-completion" >>/home/vagrant/.bashrc
echo "[[ -f /opt/cylc/conf/cylc-bash-completion ]] && . /opt/cylc/conf/cylc-bash-completion" >>/home/vagrant/.bashrc

#### Configure firefox as the default PDF viewer
sudo -u $(logname) mkdir -p /home/vagrant/.local/share/applications
sudo -u $(logname) bash -c 'echo "[Added Associations]" >/home/vagrant/.local/share/applications/mimeapps.list'
sudo -u $(logname) bash -c 'echo "application/pdf=firefox.desktop;" >>/home/vagrant/.local/share/applications/mimeapps.list'

#### Configure cylc review & rosie web services (with a local rosie repository)
if [[ $dist == ubuntu ]]; then
  if [[ $release != 2204 ]]; then
    apt-get install -q -y apache2 libapache2-mod-wsgi python-cherrypy3 apache2-utils python-sqlalchemy || error
  else
    apt-get install -q -y apache2 apache2-dev apache2-utils || error
    pip2 install cherrypy sqlalchemy || error
    curl -L -s -S https://codeload.github.com/GrahamDumpleton/mod_wsgi/tar.gz/4.9.3 | tar -xz
    cd mod_wsgi-4.9.3
    ./configure --with-python=/usr/bin/python2
    make
    make install
    cd ..
    rm -r mod_wsgi-4.9.3
    echo "LoadModule wsgi_module /usr/lib/apache2/modules/mod_wsgi.so" > /etc/apache2/mods-enabled/wsgi.conf
  fi
  if [[ $release == 1604 ]]; then
    apt-get install -q -y libapache2-svn || error
  else
    apt-get install -q -y libapache2-mod-svn || error
  fi
elif [[ $dist == redhat ]]; then
  if [[ $release == centos8 ]]; then
    yum install -y mod_dav_svn python2-sqlalchemy httpd-devel || error
    pip2 install mod_wsgi || error
    echo "LoadModule wsgi_module /usr/lib64/python2.7/site-packages/mod_wsgi/server/mod_wsgi-py27.so" > /etc/httpd/conf.modules.d/10-wsgi.conf
  else
    yum install -y mod_dav_svn mod_wsgi python-cherrypy python-sqlalchemy || error
  fi
fi
# Configure apache
mkdir -p /opt/metomi-site/etc/httpd
dos2unix -n /vagrant/opt/metomi-site/etc/httpd/rosie-wsgi.conf /opt/metomi-site/etc/httpd/rosie-wsgi.conf
if [[ $dist == ubuntu ]]; then
  dos2unix -n /vagrant/opt/metomi-site/etc/httpd/svn.conf /opt/metomi-site/etc/httpd/svn.conf
elif [[ $dist == redhat ]]; then
  dos2unix -n /vagrant/opt/metomi-site/etc/httpd/svn.conf.redhat /opt/metomi-site/etc/httpd/svn.conf
fi
ln -sf /opt /var/www/html
dos2unix -n /vagrant/var/www/html/index.html /var/www/html/index.html
if [[ $dist == ubuntu ]]; then
  ln -sf /opt/metomi-site/etc/httpd/rosie-wsgi.conf /etc/apache2/conf-enabled/rosie-wsgi.conf
  ln -sf /opt/metomi-site/etc/httpd/svn.conf /etc/apache2/conf-enabled/svn.conf
  if [[ $release == 2204 ]]; then
    echo "WSGIPythonPath /usr/local/lib/python2.7/dist-packages:/opt/rose/lib/python" >> /etc/apache2/conf-enabled/rosie-wsgi.conf
  fi
  service apache2 restart || error
elif [[ $dist == redhat ]]; then
  ln -sf /opt/metomi-site/etc/httpd/rosie-wsgi.conf /etc/httpd/conf.d/rosie-wsgi.conf
  if [[ $release == centos7 ]]; then
    rm /etc/httpd/conf.d/subversion.conf
  fi
  ln -sf /opt/metomi-site/etc/httpd/svn.conf /etc/httpd/conf.d/subversion.conf
  service httpd start || error
  chkconfig --level 345 httpd on || error
fi
# cylc review needs to be able to access cylc-run directory
chmod 755 /home/vagrant
sudo -u $(logname) mkdir -p /home/vagrant/cylc-run
# Setup the rosie repository
mkdir /srv/svn
if [[ $dist == ubuntu ]]; then
  sudo chown www-data /srv/svn
  sudo -u www-data svnadmin create /srv/svn/roses-tmp
elif [[ $dist == redhat ]]; then
  sudo chown apache /srv/svn
  sudo -u apache svnadmin create /srv/svn/roses-tmp
fi
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
if [[ $dist == ubuntu ]]; then
  sudo -u www-data /opt/rose/sbin/rosa db-create || error
elif [[ $dist == redhat ]]; then
  sudo -u apache /opt/rose/sbin/rosa db-create || error
fi

#### Miscellaneous utilities
dos2unix -n /vagrant/usr/local/bin/install-iris /usr/local/bin/install-iris
dos2unix -n /vagrant/usr/local/bin/install-jules-benchmark-data /usr/local/bin/install-jules-benchmark-data
dos2unix -n /vagrant/usr/local/bin/install-jules-extras /usr/local/bin/install-jules-extras
dos2unix -n /vagrant/usr/local/bin/install-jules-gswp2-data /usr/local/bin/install-jules-gswp2-data
dos2unix -n /vagrant/usr/local/bin/install-master-versions /usr/local/bin/install-master-versions
dos2unix -n /vagrant/usr/local/bin/install-nvidia /usr/local/bin/install-nvidia
dos2unix -n /vagrant/usr/local/bin/install-ukca-data /usr/local/bin/install-ukca-data
dos2unix -n /vagrant/usr/local/bin/install-um-data /usr/local/bin/install-um-data
dos2unix -n /vagrant/usr/local/bin/install-um-extras /usr/local/bin/install-um-extras
dos2unix -n /vagrant/usr/local/bin/run-test-batteries /usr/local/bin/run-test-batteries
dos2unix -n /vagrant/usr/local/bin/um-setup /usr/local/bin/um-setup

if [[ $dist == redhat && $release == fedora* ]]; then
  # Allow these commands to be found via sudo
  echo "Defaults:vagrant secure_path = /sbin:/bin:/usr/sbin:/usr/bin:/usr/local/bin" >/etc/sudoers.d/vagrant-path
fi
