# Define software versions
FCM_VERSION=2015.03.0
CYLC_VERSION=6.3.1
ROSE_VERSION=2015.03.0

#### Install commonly used editors
yum install -y gedit gvim emacs
# Set the default editor in .bash_profile
echo "export EDITOR=gedit" >>.bash_profile

#### Disable SELinux to keep things simple
setenforce 0
perl -pi -e 's/^SELINUX=enforcing/SELINUX=disabled/;' /etc/selinux/config

#### Install FCM
yum install -y subversion firefox tkcvs kdiff3 perl-core perl-XML-Parser
yum install -y m4 perl-Config-IniFiles subversion-perl
yum install -y gcc-c++  # used by fcm test-battery
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
yum install -y graphviz python-jinja2 pygtk2 at
service atd start
yum install -y lsof
yum install -y graphviz-devel python-devel
easy_install pygraphviz
easy_install pyro==3.16
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
yum install -y python-simplejson rsync xterm
yum install -y gcc-gfortran # gfortran is used in the brief tour suite
easy_install requests
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
dos2unix -n /vagrant/opt/metomi-site/etc/rose.conf /opt/metomi-site/etc/rose.conf
ln -sf /opt/metomi-site/etc/rose.conf /opt/rose-$ROSE_VERSION/etc/rose.conf
ln -sf /opt/metomi-site/etc/rose.conf /opt/rose-master/etc/rose.conf

#### Configure syntax highlighting & bash completion
sudo -u vagrant mkdir -p /home/vagrant/.local/share/gtksourceview-3.0/language-specs/
sudo -u vagrant ln -sf /opt/cylc/conf/cylc.lang /home/vagrant/.local/share/gtksourceview-3.0/language-specs
sudo -u vagrant ln -sf /opt/rose/etc/rose-conf.lang /home/vagrant/.local/share/gtksourceview-3.0/language-specs
sudo -u vagrant mkdir -p /home/vagrant/.vim/syntax
sudo -u vagrant ln -sf /opt/cylc/conf/cylc.vim /home/vagrant/.vim/syntax
sudo -u vagrant ln -sf /opt/rose/etc/rose-conf.vim /home/vagrant/.vim/syntax
sudo -u vagrant dos2unix -n /vagrant/home/.vimrc /home/vagrant/.vimrc
sudo -u vagrant mkdir -p /home/vagrant/.emacs.d
sudo -u vagrant ln -sf /opt/cylc/conf/cylc-mode.el /home/vagrant/.emacs.d
sudo -u vagrant ln -sf /opt/rose/etc/rose-conf-mode.el /home/vagrant/.emacs.d
sudo -u vagrant dos2unix -n /vagrant/home/.emacs /home/vagrant/.emacs
echo '[[ "$-" != *i* ]] && return # Stop here if not running interactively' >>/home/vagrant/.bashrc
echo "[[ -f /opt/rose/etc/rose-bash-completion ]] && . /opt/rose/etc/rose-bash-completion" >>/home/vagrant/.bashrc

#### Configure rose bush & rosie web services (with a local rosie repository)
yum install -y mod_dav_svn mod_wsgi python-cherrypy python-sqlalchemy
# Configure apache
mkdir -p /opt/metomi-site/etc/httpd
dos2unix -n /vagrant/opt/metomi-site/etc/httpd/rosie-wsgi.conf /opt/metomi-site/etc/httpd/rosie-wsgi.conf
ln -sf /opt/metomi-site/etc/httpd/rosie-wsgi.conf /etc/httpd/conf.d/rosie-wsgi.conf
dos2unix -n /vagrant/opt/metomi-site/etc/httpd/svn.conf /opt/metomi-site/etc/httpd/svn.conf
rm /etc/httpd/conf.d/subversion.conf
ln -sf /opt/metomi-site/etc/httpd/svn.conf /etc/httpd/conf.d/subversion.conf
service httpd start
chkconfig --level 345 httpd on
chmod 755 /home/vagrant # rose bush needs to be able to access cylc-run directory
# Setup the rosie repository
mkdir /srv/svn
sudo chown apache /srv/svn
sudo -u apache svnadmin create /srv/svn/roses-tmp
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
sudo -u apache /opt/rose/sbin/rosa db-create
