# Define software versions
FCM_VERSION=2015.09.0
CYLC_VERSION=6.7.0
ROSE_VERSION=2015.10.0

if [[ $dist == ubuntu ]]; then
  #### Remove some packages we don't need
  apt-get remove -y chef puppet
  apt-get autoremove -y
elif [[ $dist == centos ]]; then
  #### Disable SELinux to keep things simple
  yum install -y perl
  setenforce 0
  perl -pi -e 's/^SELINUX=enforcing/SELINUX=disabled/;' /etc/selinux/config
fi

#### Install commonly used editors
if [[ $dist == ubuntu ]]; then
  apt-get install -y dictionaries-common # leaving this to be installed automatically results in errors
  apt-get install -y gedit vim-gtk emacs
  # Set the default editor in .profile
  echo "export EDITOR=gedit" >>.profile
elif [[ $dist == centos ]]; then
  yum install -y gedit gvim emacs
  # Set the default editor in .bash_profile
  echo "export EDITOR=gedit" >>.bash_profile
fi

#### Install FCM
if [[ $dist == ubuntu ]]; then
  apt-get install -y subversion firefox tkcvs tk kdiff3 libxml-parser-perl
  apt-get install -y m4 libconfig-inifiles-perl libdbi-perl g++ libsvn-perl
elif [[ $dist == centos ]]; then
  yum install -y subversion firefox tkcvs kdiff3 perl-core perl-XML-Parser
  yum install -y perl-Config-IniFiles subversion-perl
  yum install -y gcc-c++  # used by fcm test-battery
  if [[ $release == 6 ]]; then
    yum install -y perl-DBI
  elif [[ $release == 6 ]]; then
    yum install -y m4
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
  apt-get install -y graphviz pyro python-jinja2 python-pygraphviz python-gtk2 sqlite3
elif [[ $dist == centos && $release == 6 ]]; then
  yum install -y graphviz at
  service atd start
  yum install -y lsof
  yum install -y python-setuptools graphviz-devel python-devel gcc
  easy_install pygraphviz
  easy_install jinja2
  easy_install pyro==3.16
elif [[ $dist == centos && $release == 7 ]]; then
  yum install -y graphviz python-jinja2 pygtk2 at
  service atd start
  yum install -y lsof
  yum install -y graphviz-devel python-devel
  easy_install pygraphviz
  easy_install pyro==3.16
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
elif [[ $dist == centos ]]; then
  yum install -y python-simplejson rsync xterm
  yum install -y gcc-gfortran # gfortran is used in the brief tour suite
  easy_install requests
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
elif [[ $dist == centos ]]; then
  dos2unix -n /vagrant/opt/metomi-site/etc/rose.conf.centos /opt/metomi-site/etc/rose.conf
fi
ln -sf /opt/metomi-site/etc/rose.conf /opt/rose-$ROSE_VERSION/etc/rose.conf
ln -sf /opt/metomi-site/etc/rose.conf /opt/rose-master/etc/rose.conf

#### Configure syntax highlighting & bash completion
if [[ $dist == centos && $release == 6 ]]; then
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
if [[ $dist == centos ]]; then
  echo '[[ "$-" != *i* ]] && return # Stop here if not running interactively' >>/home/vagrant/.bashrc
fi
echo "[[ -f /opt/rose/etc/rose-bash-completion ]] && . /opt/rose/etc/rose-bash-completion" >>/home/vagrant/.bashrc

#### Configure rose bush & rosie web services (with a local rosie repository)
if [[ $dist == ubuntu ]]; then
  apt-get install -y apache2 libapache2-mod-wsgi python-cherrypy3 libapache2-svn apache2-utils python-sqlalchemy
elif [[ $dist == centos && $release == 6 ]]; then
  yum install -y mod_dav_svn mod_wsgi python-cherrypy
  easy_install sqlalchemy
elif [[ $dist == centos && $release == 7 ]]; then
  yum install -y mod_dav_svn mod_wsgi python-cherrypy python-sqlalchemy
fi
# Configure apache
mkdir -p /opt/metomi-site/etc/httpd
if [[ $dist == centos && $release == 6 ]]; then
  dos2unix -n /vagrant/opt/metomi-site/etc/httpd/rosie-wsgi.conf.centos-6 /opt/metomi-site/etc/httpd/rosie-wsgi.conf
else
  dos2unix -n /vagrant/opt/metomi-site/etc/httpd/rosie-wsgi.conf /opt/metomi-site/etc/httpd/rosie-wsgi.conf
fi
if [[ $dist == ubuntu ]]; then
  dos2unix -n /vagrant/opt/metomi-site/etc/httpd/svn.conf /opt/metomi-site/etc/httpd/svn.conf
elif [[ $dist == centos ]]; then
  dos2unix -n /vagrant/opt/metomi-site/etc/httpd/svn.conf.centos /opt/metomi-site/etc/httpd/svn.conf
fi
if [[ $dist == ubuntu ]]; then
  ln -sf /opt/metomi-site/etc/httpd/rosie-wsgi.conf /etc/apache2/conf-enabled/rosie-wsgi.conf
  ln -sf /opt/metomi-site/etc/httpd/svn.conf /etc/apache2/conf-enabled/svn.conf
  service apache2 restart
elif [[ $dist == centos ]]; then
  ln -sf /opt/metomi-site/etc/httpd/rosie-wsgi.conf /etc/httpd/conf.d/rosie-wsgi.conf
  rm /etc/httpd/conf.d/subversion.conf
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
elif [[ $dist == centos ]]; then
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
elif [[ $dist == centos ]]; then
  sudo -u apache /opt/rose/sbin/rosa db-create
fi

#### Miscellaneous utilities
dos2unix -n /vagrant/usr/local/bin/run-test-batteries /usr/local/bin/run-test-batteries
dos2unix -n /vagrant/usr/local/bin/install-jules-extras /usr/local/bin/install-jules-extras
dos2unix -n /vagrant/usr/local/bin/install-jules-gswp2-data /usr/local/bin/install-jules-gswp2-data
