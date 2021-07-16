#### Install the X2Go for desktop connections - only for Ubuntu currently
if [[ $dist == ubuntu ]]; then
  if [[ $release == 1804 ]]; then
    apt-get install -q -y software-properties-common || error
    add-apt-repository -y ppa:x2go/stable || error
    apt-get -q -y update || error
    apt-get install -q -y x2goserver x2goserver-xsession x2golxdebindings || error
  fi
fi
