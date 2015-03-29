# Define software versions
FCM_VERSION=2015.03.0
CYLC_VERSION=6.3.1
ROSE_VERSION=2015.03.0

#### Remove some packages we don't need
apt-get remove -y chef puppet

#### Install commonly used editors
apt-get install -y dictionaries-common # leaving this to be installed automatically results in errors
apt-get install -y gedit vim-gtk emacs
# Set the default editor in .profile
echo "export EDITOR=gedit" >>.profile

#### Install FCM
apt-get install -y subversion firefox tkcvs tk kdiff3 libxml-parser-perl
apt-get install -y m4 libconfig-inifiles-perl libdbi-perl g++ libsvn-perl
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
apt-get install -y graphviz pyro python-jinja2 python-pygraphviz python-gtk2 sqlite3
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
apt-get install -y gfortran # gfortran is used in the brief tour suite
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
sudo -u vagrant mkdir -p /home/vagrant/.local/share/gtksourceview-2.0/language-specs/
sudo -u vagrant ln -sf /opt/cylc/conf/cylc.lang /home/vagrant/.local/share/gtksourceview-2.0/language-specs
sudo -u vagrant ln -sf /opt/rose/etc/rose-conf.lang /home/vagrant/.local/share/gtksourceview-2.0/language-specs
sudo -u vagrant mkdir -p /home/vagrant/.vim/syntax
sudo -u vagrant ln -sf /opt/cylc/conf/cylc.vim /home/vagrant/.vim/syntax
sudo -u vagrant ln -sf /opt/rose/etc/rose-conf.vim /home/vagrant/.vim/syntax
sudo -u vagrant dos2unix -n /vagrant/home/.vimrc /home/vagrant/.vimrc
sudo -u vagrant mkdir -p /home/vagrant/.emacs.d
sudo -u vagrant ln -sf /opt/cylc/conf/cylc-mode.el /home/vagrant/.emacs.d
sudo -u vagrant ln -sf /opt/rose/etc/rose-conf-mode.el /home/vagrant/.emacs.d
sudo -u vagrant dos2unix -n /vagrant/home/.emacs /home/vagrant/.emacs
echo "[[ -f /opt/rose/etc/rose-bash-completion ]] && . /opt/rose/etc/rose-bash-completion" >>/home/vagrant/.bashrc

#### Configure rose bush & rosie web services (with a local rosie repository)
apt-get install -y apache2 libapache2-mod-wsgi python-cherrypy3 libapache2-svn apache2-utils python-sqlalchemy
# Configure apache
mkdir -p /opt/metomi-site/etc/httpd
dos2unix -n /vagrant/opt/metomi-site/etc/httpd/rosie-wsgi.conf /opt/metomi-site/etc/httpd/rosie-wsgi.conf
ln -sf /opt/metomi-site/etc/httpd/rosie-wsgi.conf /etc/apache2/conf-enabled/rosie-wsgi.conf
dos2unix -n /vagrant/opt/metomi-site/etc/httpd/svn.conf /opt/metomi-site/etc/httpd/svn.conf
ln -sf /opt/metomi-site/etc/httpd/svn.conf /etc/apache2/conf-enabled/svn.conf
service apache2 restart
# Setup the rosie repository
mkdir /srv/svn
sudo chown www-data /srv/svn
sudo -u www-data svnadmin create /srv/svn/roses-tmp
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
sudo -u www-data /opt/rose/sbin/rosa db-create
