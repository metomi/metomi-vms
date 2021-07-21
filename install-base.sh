if [[ $dist == redhat ]]; then
  #### Disable SELinux to keep things simple
  setenforce 0 || error
  perl -pi -e 's/^SELINUX=enforcing/SELINUX=disabled/;' /etc/selinux/config
fi

if [[ $dist == redhat && $release == fedora* ]]; then
  #### Enable X applications to open the display
  yum install -y xauth || error
fi

#### Install commonly used editors
if [[ $dist == ubuntu ]]; then
  apt-get install -q -y leafpad vim-gtk emacs || error
  # Set the default editor in .profile
  echo "export EDITOR=leafpad" >>.profile
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
  yum install -y subversion firefox tkcvs perl-core perl-XML-Parser || error
  yum install -y perl-Config-IniFiles subversion-perl || error
  yum install -y gcc-c++ || error  # used by fcm test-battery
  if [[ $release == fedora* ]]; then
    yum install -y m4 perl-DBI || error
    yum install -y xxdiff || error
  else
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
  apt-get install -q -y graphviz python-jinja2 python-pygraphviz python-gtk2 sqlite3 || error
  apt-get install -q -y pep8 || error # used by test-battery
  if [[ $release != 1604 ]]; then
    : # Rose docs build no longer working - disable for the moment
    #apt-get install -q -y imagemagick || error
  fi
elif [[ $dist == redhat ]]; then
  yum install -y python-pip graphviz at lsof python-pep8 || error
  service atd start || error
  yum install -y graphviz-devel python-devel || error
  if [[ $release == fedora* ]]; then
    yum install -y redhat-rpm-config sqlite pyOpenSSL || error
    yum install -y ImageMagick || error
  fi
  yum install -y python-jinja2 pygtk2 || error
  if [[ $release == centos7 ]]; then
    pip install pygraphviz || error
  else
    yum install -y python-pygraphviz || error
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
  apt-get install -q -y python-pip pcregrep || error
  apt-get install -q -y lxterminal || error # rose edit is configured to use this
  apt-get install -q -y tidy || error
  apt-get install -q -y python-requests python-simplejson || error
  apt-get install -q -y python-virtualenv || error # needed by rose make-docs
elif [[ $dist == redhat ]]; then
  yum install -y python-simplejson rsync xterm || error
  yum install -y gcc-gfortran || error # gfortran is used in the brief tour suite
  yum install -y python-requests || error
  yum install -y pcre-tools || error
  if [[ $release == fedora* ]]; then
    yum install -y python2-virtualenv || error # needed by rose make-docs
  fi
fi
pip install mock pytest-tap # used by test-battery
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
dos2unix -n /vagrant/usr/local/bin/install-rose-cylc-fcm /usr/local/bin/install-rose-cylc-fcm
/usr/local/bin/install-rose-cylc-fcm --set-default --make-docs || error

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
  apt-get install -q -y apache2 libapache2-mod-wsgi python-cherrypy3 apache2-utils python-sqlalchemy || error
  if [[ $release != 1804 ]]; then
    apt-get install -q -y libapache2-svn || error
  else
    apt-get install -q -y libapache2-mod-svn || error
  fi
elif [[ $dist == redhat ]]; then
  yum install -y mod_dav_svn mod_wsgi python-cherrypy python-sqlalchemy || error
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
  service apache2 restart || error
elif [[ $dist == redhat ]]; then
  ln -sf /opt/metomi-site/etc/httpd/rosie-wsgi.conf /etc/httpd/conf.d/rosie-wsgi.conf
  if [[ $release == centos* ]]; then
    rm /etc/httpd/conf.d/subversion.conf
  fi
  ln -sf /opt/metomi-site/etc/httpd/svn.conf /etc/httpd/conf.d/subversion.conf
  service httpd start || error
  chkconfig --level 345 httpd on || error
  chmod 755 /home/vagrant # cylc review needs to be able to access cylc-run directory
fi
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
cd /home/vagrant
sudo -H -u $(logname) bash -c 'svn co -q --config-option config:auth:password-stores= --config-option=servers:global:store-plaintext-passwords=yes --password "vagrant" http://localhost/svn/roses-tmp'
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
dos2unix -n /vagrant/usr/local/bin/install-ukca-data /usr/local/bin/install-ukca-data
dos2unix -n /vagrant/usr/local/bin/install-um-data /usr/local/bin/install-um-data
dos2unix -n /vagrant/usr/local/bin/install-um-extras /usr/local/bin/install-um-extras
dos2unix -n /vagrant/usr/local/bin/run-test-batteries /usr/local/bin/run-test-batteries
dos2unix -n /vagrant/usr/local/bin/um-setup /usr/local/bin/um-setup

if [[ $dist == redhat && $release == fedora* ]]; then
  # Allow these commands to be found via sudo
  echo "Defaults:vagrant secure_path = /sbin:/bin:/usr/sbin:/usr/bin:/usr/local/bin" >/etc/sudoers.d/vagrant-path
fi
