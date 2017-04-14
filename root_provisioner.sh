export DEBIAN_FRONTEND=noninteractive
export VERTICA_DOWNLOAD_URL=https://my.vertica.com/client_drivers/8.0.x/8.0.1/vertica-client-8.0.1-0.x86_64.tar.gz
export PYTHON_DOWNLOAD_URL=https://www.python.org/ftp/python/2.7.13/Python-2.7.13.tgz
echo "Downloading Vertica"
function md5check()
{
   check=`md5sum $1 | cut -d ' ' -f1`
  if [ "$check" = "$2" ]; then
    return 0
  else
    return 1
  fi
}

function install_oh_my_zsh {

  local change_user="$1"
  local change_user_home="$2"
  local ohmyzsh_repo='https://raw.githubusercontent.com/robbyrussell/oh-my-zsh'

  # copy zshrc template to .zshrc in user home
  cp "/etc/zsh/newuser.zshrc.recommended" "$change_user_home/.zshrc"
  chown "$change_user:$change_user" "$change_user_home/.zshrc"
  echo "copying zshrc template to $change_user_home/.zshrc"

  # change default shell to zsh
  chsh -s "$(which zsh)" "$change_user"
  echo "default shell changed to zsh for user '$change_user'"

  # download install script
  curl -fsSL "$ohmyzsh_repo/master/tools/install.sh" \
    -o "$change_user_home/install_ohmyzsh.sh"
  echo "oh-my-zsh install script downloaded to" \
       "$change_user_home/install_ohmyzsh.sh"

  # install oh-my-zsh
  if [ ! -d "$change_user_home/.oh-my-zsh" ]; then

    if [ "$change_user" == 'root' ]; then
      sh "$change_user_home/install_ohmyzsh.sh"
    else
      su -c "sh '$change_user_home/install_ohmyzsh.sh'" "$change_user"
    fi

    # change zsh theme
    sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="bira"/' \
      "$change_user_home/.zshrc"

cat >> "$change_user_home/.zshrc"  <<- 'EOF'
export VIRTUALENVWRAPPER_PYTHON=/usr/local/bin/python2.7
export VIRTUALENVWRAPPER_VIRTUALENV_ARGS='--no-site-packages'
source ~/.local/bin/virtualenvwrapper.sh
export WORKON_HOME=$HOME/.virtualenvs
export PIP_VIRTUALENV_BASE=$WORKON_HOME
export PIP_RESPECT_VIRTUALENV=true
export PATH=~/.local/bin:$PATH
EOF

    # make sure that .zshrc is owned by user
    chown "$change_user:$change_user" "$change_user_home/.zshrc"

    echo "oh-my-zsh installed for user $change_user"
  else
    echo "oh-my-zsh alredy installed for user $change_user, skipping"
  fi

  # remove install script, goodbye
  rm -f "$change_user_home/install_ohmyzsh.sh"

}


apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D > /dev/null 2>&1
echo deb https://apt.dockerproject.org/repo ubuntu-trusty main > /etc/apt/sources.list.d/docker.list

apt-get -y -qq update
add-apt-repository -y ppa:git-core/ppa > /dev/null 2>&1

apt-get -y -qq update

apt-get -y -qq install build-essential \
checkinstall \
libreadline-gplv2-dev \
libncursesw5-dev \
libssl-dev \
libsqlite3-dev \
tk-dev \
libgdbm-dev \
libc6-dev \
libbz2-dev \
libpq-dev \
libffi-dev \
ncurses-dev \
git \
libcurl4-openssl-dev \
aufs-tools \
zsh \
docker-engine=1.13.1-0~ubuntu-trusty > /dev/null 2>&1


chsh -s /bin/zsh vagrant

install_oh_my_zsh 'root' '/root'
install_oh_my_zsh 'vagrant' '/home/vagrant' > /dev/null 2>&1

# collect all the files
mkdir -p ~vagrant/.simplereach/build
cd ~vagrant/.simplereach/build

# add check for local file, error checking, early exit and message if error
echo "Downloading Python"
wget -q $PYTHON_DOWNLOAD_URL
echo "Downloading Vertica"
wget -q $VERTICA_DOWNLOAD_URL

echo "installing vertica"
tar -xzf vertica-client-8.0.1-0.x86_64.tar.gz
cp opt/vertica/bin/vsql /usr/local/bin/
chmod a+x /usr/local/bin/vsql
mkdir -p /var/log/vertica && touch /var/log/vertica/rejected.log && touch /var/log/vertica/exceptions.log && chown -R vagrant /var/log/vertica
rm -rf opt
chown -R vagrant.vagrant ~vagrant/.simplereach

echo "installing python source"
# install python TODO: find a ubuntu package for this
tar -xzf Python-2.7.13.tgz > /dev/null 2>&1
cd Python-2.7.13 && ./configure -q && make altinstall > /dev/null 2>&1
cd ../
rm -rf Python-2.7.13*
ln -s /usr/local/bin/python2.7 /usr/local/bin/python


mkdir -p /etc/simplereach
# config file for postgres
cat > /etc/simplereach/postgres.json  <<- 'EOF'
 {
   "database": "skycutter_development",
   "username": "",
   "password": "",
   "host": "localhost",
   "port": "5432"
 }
EOF

# config file for vertica
cat > /etc/simplereach/vertica.json  <<- 'EOF'
{ "VSQL_PATH": "/usr/local/bin/vsql",
  "REJECTED_LOG": "/var/log/vertica/rejected.log",
  "EXCEPTIONS_LOG": "/var/log/vertica/exceptions.log",
  "LOG_DIR": "/var/log"
}
EOF


curl -sL https://github.com/docker/compose/releases/download/1.8.1/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose > /dev/null
chmod a+x /usr/local/bin/docker-compose
# add vagrant to the docker group so it can access the socket
usermod -aG docker vagrant
