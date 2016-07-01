# Define software versions
FCM_VERSION=2016.05.1
CYLC_VERSION=6.10.2
ROSE_VERSION=2016.06.0

if [[ $dist == ubuntu ]]; then
  #### Remove some packages we don't need
  apt-get remove --auto-remove -y chef puppet
elif [[ $dist == redhat ]]; then
  #### Disable SELinux to keep things simple
  yum install -y perl
  setenforce 0
  perl -pi -e 's/^SELINUX=enforcing/SELINUX=disabled/;' /etc/selinux/config
fi

if [[ $dist == redhat && $release == fedora23 ]]; then
  #### Enable X applications to open the display
  yum install -y xauth
fi

#### Install commonly used editors
if [[ $dist == ubuntu ]]; then
  apt-get install -y dictionaries-common # leaving this to be installed automatically results in errors
  apt-get install -y gedit vim-gtk emacs
  # Set the default editor in .profile
  echo "export SVN_EDITOR='gvim -f'" >>.profile
  echo "export EDITOR=gedit" >>.profile
elif [[ $dist == redhat ]]; then
  if [[ $release == fedora23 ]]; then
    # gvim fails to install unless vim-minimal is updated first
    yum update -y vim-minimal
  fi
  yum install -y gedit gvim emacs
  # Set the default editor in .bash_profile
  echo "export SVN_EDITOR='gvim -f'" >>.bash_profile
  echo "export EDITOR=gedit" >>.bash_profile
fi

#### Install FCM
if [[ $dist == ubuntu ]]; then
  apt-get install -y subversion firefox tkcvs tk kdiff3 libxml-parser-perl
  apt-get install -y m4 libconfig-inifiles-perl libdbi-perl g++ libsvn-perl
elif [[ $dist == redhat ]]; then
  yum install -y subversion firefox tkcvs kdiff3 perl-core perl-XML-Parser
  yum install -y perl-Config-IniFiles subversion-perl
  yum install -y gcc-c++  # used by fcm test-battery
  if [[ $release == fedora23 ]]; then
    yum install -y m4 perl-DBI
  fi
fi
# Get FCM from github
svn export -q https://github.com/metomi/fcm/tags/$FCM_VERSION /opt/fcm-$FCM_VERSION
# Create a symlink to make this the default version
ln -sf /opt/fcm-$FCM_VERSION /opt/fcm
# Also checkout the latest version of master for test purposes
svn co -q https://github.com/metomi/fcm/trunk /opt/fcm-master
# Add the fcm wrapper script
dos2unix -n /vagrant/usr/local/bin/fcm /usr/local/bin/fcm
# Configure FCM diff and merge viewers
mkdir -p /opt/metomi-site/etc/fcm
dos2unix -n /vagrant/opt/metomi-site/etc/fcm/external.cfg /opt/metomi-site/etc/fcm/external.cfg
ln -sf /opt/metomi-site/etc/fcm/external.cfg /opt/fcm-$FCM_VERSION/etc/fcm/external.cfg
ln -sf /opt/metomi-site/etc/fcm/external.cfg /opt/fcm-master/etc/fcm/external.cfg

#### Install Cylc
if [[ $dist == ubuntu ]]; then
  apt-get install -y graphviz python-jinja2 python-pygraphviz python-gtk2 sqlite3
  apt-get install -y pep8 # used by test-battery
elif [[ $dist == redhat ]]; then
  yum install -y python-setuptools graphviz at lsof python-pep8
  service atd start
  yum install -y graphviz-devel python-devel
  if [[ $release == fedora23 ]]; then
    yum install -y redhat-rpm-config
  fi
  easy_install pygraphviz
  if [[ $release == centos6 ]]; then
    easy_install jinja2
  else
    yum install -y python-jinja2 pygtk2
  fi
  # Ensure "hostname -f" returns the fully qualified name
  perl -pi -e 's/localhost localhost.localdomain/localhost.localdomain localhost/;' /etc/hosts
fi
# Get Cylc from github
svn export -q https://github.com/cylc/cylc/tags/$CYLC_VERSION /opt/cylc-$CYLC_VERSION
# Create a symlink to make this the default version
ln -sf /opt/cylc-$CYLC_VERSION /opt/cylc
# Also checkout the latest version of master for test purposes
svn co -q https://github.com/cylc/cylc/trunk /opt/cylc-master
# Add the Cylc wrapper scripts
dos2unix -n /vagrant/usr/local/bin/cylc /usr/local/bin/cylc
cd /usr/local/bin
ln -sf cylc gcylc
# Create the version file
cd /opt/cylc-$CYLC_VERSION
make version
cd /opt/cylc-master
make version
# Configure additional copyable environment variables
mkdir -p /opt/metomi-site/conf
dos2unix -n /vagrant/opt/metomi-site/conf/global.rc /opt/metomi-site/conf/global.rc
ln -sf /opt/metomi-site/conf/global.rc /opt/cylc-$CYLC_VERSION/conf/global.rc
ln -sf /opt/metomi-site/conf/global.rc /opt/cylc-master/conf/global.rc

#### Install Rose
if [[ $dist == ubuntu ]]; then
  apt-get install -y gfortran # gfortran is used in the brief tour suite
  if [[ $release == 1504 ]]; then
    apt-get install -y python-requests
  fi
elif [[ $dist == redhat ]]; then
  yum install -y python-simplejson rsync xterm
  yum install -y gcc-gfortran # gfortran is used in the brief tour suite
  if [[ $release == centos6 ]]; then
    easy_install requests
  else
    yum install -y python-requests
  fi
fi
# Get Rose from github
svn export -q https://github.com/metomi/rose/tags/$ROSE_VERSION /opt/rose-$ROSE_VERSION
# Create a symlink to make this the default version
ln -sf /opt/rose-$ROSE_VERSION /opt/rose
# Also checkout the latest version of master for test purposes
svn co -q https://github.com/metomi/rose/trunk /opt/rose-master
# Add the Rose wrapper scripts
dos2unix -n /vagrant/usr/local/bin/rose /usr/local/bin/rose
cd /usr/local/bin
ln -sf rose rosie
# Configure Rose
if [[ $dist == ubuntu ]]; then
  dos2unix -n /vagrant/opt/metomi-site/etc/rose.conf /opt/metomi-site/etc/rose.conf
elif [[ $dist == redhat ]]; then
  dos2unix -n /vagrant/opt/metomi-site/etc/rose.conf.redhat /opt/metomi-site/etc/rose.conf
fi
ln -sf /opt/metomi-site/etc/rose.conf /opt/rose-$ROSE_VERSION/etc/rose.conf
ln -sf /opt/metomi-site/etc/rose.conf /opt/rose-master/etc/rose.conf

#### Configure syntax highlighting & bash completion
if [[ $dist == redhat && $release == centos6 ]]; then
  sudo -u vagrant mkdir -p /home/vagrant/.local/share/gtksourceview-2.0/language-specs/
  sudo -u vagrant ln -sf /opt/cylc/conf/cylc.lang /home/vagrant/.local/share/gtksourceview-2.0/language-specs
  sudo -u vagrant ln -sf /opt/rose/etc/rose-conf.lang /home/vagrant/.local/share/gtksourceview-2.0/language-specs
else
  sudo -u vagrant mkdir -p /home/vagrant/.local/share/gtksourceview-3.0/language-specs/
  sudo -u vagrant ln -sf /opt/cylc/conf/cylc.lang /home/vagrant/.local/share/gtksourceview-3.0/language-specs
  sudo -u vagrant ln -sf /opt/rose/etc/rose-conf.lang /home/vagrant/.local/share/gtksourceview-3.0/language-specs
fi
sudo -u vagrant mkdir -p /home/vagrant/.vim/syntax
sudo -u vagrant ln -sf /opt/cylc/conf/cylc.vim /home/vagrant/.vim/syntax
sudo -u vagrant ln -sf /opt/rose/etc/rose-conf.vim /home/vagrant/.vim/syntax
sudo -u vagrant dos2unix -n /vagrant/home/.vimrc /home/vagrant/.vimrc
sudo -u vagrant mkdir -p /home/vagrant/.emacs.d/lisp
sudo -u vagrant ln -sf /opt/cylc/conf/cylc-mode.el /home/vagrant/.emacs.d/lisp
sudo -u vagrant ln -sf /opt/rose/etc/rose-conf-mode.el /home/vagrant/.emacs.d/lisp
sudo -u vagrant dos2unix -n /vagrant/home/.emacs /home/vagrant/.emacs
if [[ $dist == redhat ]]; then
  echo '[[ "$-" != *i* ]] && return # Stop here if not running interactively' >>/home/vagrant/.bashrc
fi
echo "[[ -f /opt/rose/etc/rose-bash-completion ]] && . /opt/rose/etc/rose-bash-completion" >>/home/vagrant/.bashrc

#### Configure rose bush & rosie web services (with a local rosie repository)
if [[ $dist == ubuntu ]]; then
  apt-get install -y apache2 libapache2-mod-wsgi python-cherrypy3 libapache2-svn apache2-utils python-sqlalchemy
elif [[ $dist == redhat ]]; then
  if [[ $release == centos6 ]]; then
    yum install -y mod_dav_svn mod_wsgi python-cherrypy
    easy_install sqlalchemy
  else
    yum install -y mod_dav_svn mod_wsgi python-cherrypy python-sqlalchemy
  fi
fi
# Configure apache
mkdir -p /opt/metomi-site/etc/httpd
if [[ $dist == redhat && $release == centos6 ]]; then
  dos2unix -n /vagrant/opt/metomi-site/etc/httpd/rosie-wsgi.conf.centos-6 /opt/metomi-site/etc/httpd/rosie-wsgi.conf
else
  dos2unix -n /vagrant/opt/metomi-site/etc/httpd/rosie-wsgi.conf /opt/metomi-site/etc/httpd/rosie-wsgi.conf
fi
if [[ $dist == ubuntu ]]; then
  dos2unix -n /vagrant/opt/metomi-site/etc/httpd/svn.conf /opt/metomi-site/etc/httpd/svn.conf
elif [[ $dist == redhat ]]; then
  dos2unix -n /vagrant/opt/metomi-site/etc/httpd/svn.conf.redhat /opt/metomi-site/etc/httpd/svn.conf
fi
if [[ $dist == ubuntu ]]; then
  ln -sf /opt/metomi-site/etc/httpd/rosie-wsgi.conf /etc/apache2/conf-enabled/rosie-wsgi.conf
  ln -sf /opt/metomi-site/etc/httpd/svn.conf /etc/apache2/conf-enabled/svn.conf
  service apache2 restart
elif [[ $dist == redhat ]]; then
  ln -sf /opt/metomi-site/etc/httpd/rosie-wsgi.conf /etc/httpd/conf.d/rosie-wsgi.conf
  if [[ $release == centos* ]]; then
    rm /etc/httpd/conf.d/subversion.conf
  fi
  ln -sf /opt/metomi-site/etc/httpd/svn.conf /etc/httpd/conf.d/subversion.conf
  service httpd start
  chkconfig --level 345 httpd on
  chmod 755 /home/vagrant # rose bush needs to be able to access cylc-run directory
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
htpasswd -b -c /srv/svn/auth.htpasswd vagrant vagrant
cd /home/vagrant
sudo -H -u vagrant bash -c 'svn co -q --config-option config:auth:password-stores= --config-option=servers:global:store-plaintext-passwords=yes --password "vagrant" http://localhost/svn/roses-tmp'
sudo -H -u vagrant bash -c 'svn ps fcm:layout -F - roses-tmp' <<EOF
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
sudo -H -u vagrant bash -c 'svn ci -m "fcm:layout: defined." roses-tmp'
rm -rf roses-tmp
mkdir -p /opt/metomi-site/etc/hooks
dos2unix -n /vagrant/opt/metomi-site/etc/hooks/pre-commit /opt/metomi-site/etc/hooks/pre-commit
ln -sf /opt/metomi-site/etc/hooks/pre-commit /srv/svn/roses-tmp/hooks/pre-commit
dos2unix -n /vagrant/opt/metomi-site/etc/hooks/post-commit /opt/metomi-site/etc/hooks/post-commit
ln -sf /opt/metomi-site/etc/hooks/post-commit /srv/svn/roses-tmp/hooks/post-commit
if [[ $dist == ubuntu ]]; then
  sudo -u www-data /opt/rose/sbin/rosa db-create
elif [[ $dist == redhat ]]; then
  sudo -u apache /opt/rose/sbin/rosa db-create
fi

#### Miscellaneous utilities
dos2unix -n /vagrant/usr/local/bin/run-test-batteries /usr/local/bin/run-test-batteries
dos2unix -n /vagrant/usr/local/bin/install-jules-extras /usr/local/bin/install-jules-extras
dos2unix -n /vagrant/usr/local/bin/install-jules-gswp2-data /usr/local/bin/install-jules-gswp2-data
dos2unix -n /vagrant/usr/local/bin/install-um-extras /usr/local/bin/install-um-extras
dos2unix -n /vagrant/usr/local/bin/um-setup /usr/local/bin/um-setup
dos2unix -n /vagrant/usr/local/bin/install-um-data /usr/local/bin/install-um-data
