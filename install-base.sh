if [[ $dist == ubuntu ]]; then
  if [[ $release == 1404 ]]; then
    #### Remove some packages we don't need
    apt-get remove -q -y --auto-remove chef puppet
  fi
elif [[ $dist == redhat ]]; then
  #### Disable SELinux to keep things simple
  yum install -y perl
  setenforce 0
  perl -pi -e 's/^SELINUX=enforcing/SELINUX=disabled/;' /etc/selinux/config
fi

if [[ $dist == redhat && $release == fedora* ]]; then
  #### Enable X applications to open the display
  yum install -y xauth
fi

#### Install commonly used editors
if [[ $dist == ubuntu ]]; then
  apt-get install -q -y dictionaries-common # leaving this to be installed automatically results in errors
  apt-get install -q -y gedit vim-gtk emacs
  # Set the default editor in .profile
  echo "export SVN_EDITOR='gvim -f'" >>.profile
  echo "export EDITOR=gedit" >>.profile
elif [[ $dist == redhat ]]; then
  if [[ $release == fedora* ]]; then
    # gvim fails to install unless vim-minimal is updated first
    yum update -y vim-minimal
  fi
  yum install -y gedit gvim emacs
  # Set the default editor in .bash_profile
  echo "export SVN_EDITOR='gvim -f'" >>.bash_profile
  echo "export EDITOR=gedit" >>.bash_profile
fi

#### Install FCM dependencies & configuration
if [[ $dist == ubuntu ]]; then
  apt-get install -q -y subversion firefox tkcvs tk kdiff3 libxml-parser-perl
  apt-get install -q -y m4 libconfig-inifiles-perl libdbi-perl g++ libsvn-perl
elif [[ $dist == redhat ]]; then
  yum install -y subversion firefox tkcvs kdiff3 perl-core perl-XML-Parser
  yum install -y perl-Config-IniFiles subversion-perl
  yum install -y gcc-c++  # used by fcm test-battery
  if [[ $release == fedora* ]]; then
    yum install -y m4 perl-DBI
  fi
fi
# Add the fcm wrapper script
dos2unix -n /vagrant/usr/local/bin/fcm /usr/local/bin/fcm
# Configure FCM diff and merge viewers
mkdir -p /opt/metomi-site/etc/fcm
dos2unix -n /vagrant/opt/metomi-site/etc/fcm/external.cfg /opt/metomi-site/etc/fcm/external.cfg

#### Install Cylc dependencies & configuration
if [[ $dist == ubuntu ]]; then
  apt-get install -q -y graphviz python-jinja2 python-pygraphviz python-gtk2 sqlite3
  apt-get install -q -y pep8 # used by test-battery
elif [[ $dist == redhat ]]; then
  yum install -y python-pip graphviz at lsof python-pep8
  service atd start
  yum install -y graphviz-devel python-devel
  if [[ $release == fedora* ]]; then
    yum install -y redhat-rpm-config sqlite pyOpenSSL
  fi
  if [[ $release == centos6 ]]; then
    pip install jinja2
    easy_install pygraphviz # pip install fails
  else
    yum install -y python-jinja2 pygtk2
    pip install pygraphviz
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
  apt-get install -q -y gfortran # gfortran is used in the brief tour suite
  apt-get install -q -y python-pip pcregrep
  if [[ $release == 16* ]]; then
    apt-get install -q -y tidy
  fi
  if [[ $release == 16* ]]; then
    apt-get install -q -y python-requests python-simplejson
  fi
elif [[ $dist == redhat ]]; then
  yum install -y python-simplejson rsync xterm
  yum install -y gcc-gfortran # gfortran is used in the brief tour suite
  if [[ $release == centos6 ]]; then
    pip install requests
  else
    yum install -y python-requests
    yum install -y pcre-tools
  fi
fi
pip install mock pytest-tap # used by test-battery
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

#### Install latest versions of FCM, Cylc & Rose 
dos2unix -n /vagrant/usr/local/bin/install-latest-versions /usr/local/bin/install-latest-versions
/usr/local/bin/install-latest-versions

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
echo "[[ -f /opt/cylc/conf/cylc-bash-completion ]] && . /opt/cylc/conf/cylc-bash-completion" >>/home/vagrant/.bashrc

#### Configure firefox as the default PDF viewer
sudo -u vagrant mkdir -p /home/vagrant/.local/share/applications
sudo -u vagrant bash -c 'echo "[Added Associations]" >/home/vagrant/.local/share/applications/mimeapps.list'
sudo -u vagrant bash -c 'echo "application/pdf=firefox.desktop;" >>/home/vagrant/.local/share/applications/mimeapps.list'

#### Configure rose bush & rosie web services (with a local rosie repository)
if [[ $dist == ubuntu ]]; then
  apt-get install -q -y apache2 libapache2-mod-wsgi python-cherrypy3 apache2-utils python-sqlalchemy
  if [[ $release == 1404 ]]; then
    apt-get install -q -y libapache2-svn
  else
    apt-get install -q -y libapache2-mod-svn
  fi
elif [[ $dist == redhat ]]; then
  if [[ $release == centos6 ]]; then
    yum install -y mod_dav_svn mod_wsgi python-cherrypy
    pip install sqlalchemy
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
dos2unix -n /vagrant/usr/local/bin/install-cylc-6 /usr/local/bin/install-cylc-6
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
