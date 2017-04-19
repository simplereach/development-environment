#!/bin/bash
eval VAGRANT_HOME=~vagrant
export VAGRANT_HOME=$VAGRANT_HOME
export DEBIAN_FRONTEND=noninteractive
export LOCAL_DIR=$VAGRANT_HOME/.local
export BUILD_DIR="$LOCAL_DIR/build"
export BIN_DIR="$LOCAL_DIR/bin"
export VERTICA_DOWNLOAD_FILE=vertica-client-8.0.1-0.x86_64.tar.gz
export VERTICA_DOWNLOAD_URL="https://my.vertica.com/client_drivers/8.0.x/8.0.1/$VERTICA_DOWNLOAD_FILE"
export PYTHON_SRC_DIR="$BUILD_DIR/Python-2.7.13"
export PYTHON_DOWNLOAD_FILE="Python-2.7.13.tgz"
export PYTHON_DOWNLOAD_URL="https://www.python.org/ftp/python/2.7.13/$PYTHON_DOWNLOAD_FILE"
export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
function exe() { echo "\$ $@" ; "$@" ; }

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
  curl -qfsSL "$ohmyzsh_repo/master/tools/install.sh" \
    -o "$change_user_home/install_ohmyzsh.sh"
  echo "oh-my-zsh install script downloaded to" \
       "$change_user_home/install_ohmyzsh.sh"

  # install oh-my-zsh
  if [ ! -d "$change_user_home/.oh-my-zsh" ]; then

    if [ "$change_user" == 'root' ]; then
      sh "$change_user_home/install_ohmyzsh.sh" > /dev/null 2>&1
    else
      su -c "sh '$change_user_home/install_ohmyzsh.sh'" "$change_user" > /dev/null 2>&1
    fi

    # change zsh theme
    sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="bira"/' \
      "$change_user_home/.zshrc"


    # make sure that .zshrc is owned by user
    chown "$change_user:$change_user" "$change_user_home/.zshrc"

    echo "oh-my-zsh installed for user $change_user"
  else
    echo "oh-my-zsh alredy installed for user $change_user, skipping"
  fi

  # remove install script, goodbye
  rm -f "$change_user_home/install_ohmyzsh.sh"

cat >> "$change_user_home/.zshrc"  <<- 'EOF'
export PATH=~/.local/bin:$PATH
export VIRTUALENVWRAPPER_PYTHON=~/.local/bin/python2.7
export VIRTUALENVWRAPPER_VIRTUALENV_ARGS='--no-site-packages'
source ~/.local/bin/virtualenvwrapper.sh
export WORKON_HOME=$HOME/.virtualenvs
export PIP_VIRTUALENV_BASE=$WORKON_HOME
export PIP_RESPECT_VIRTUALENV=true
export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
export VERTICA_LOG_DIR=/tmp/verticalogs
export LOG_DIR=/tmp/logs
export facebook_oauth_token=EAAI6x0nElXcBAP1NzieDxln8X45WMKkZBwAxFH2vz7swXWTjyXz4I6QyCD03HRyj0Mj5YXyyxSnKaUhPkhds1ZAZCR02eQ1aPPZBr9XfpL5TKqJhfrnjDgSdp4caReoMaDisznwNXm2b6qiiMfwFX5tZChwZAv8PsZD
google_oauth_client_id=1018429307889-8m2sei2rf2aseepgsqelds438mqsm53b.apps.googleusercontent.com
google_oauth_client_secret=6n1dgWoyjqcG_GLi7AuRghJs
google_oauth_refresh_token=1/-zsxHGe_kyQZ03Hfpn9GNR13KHV1Kk_hFnxbXkAkBkM`
EOF
}





apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
echo deb https://apt.dockerproject.org/repo ubuntu-trusty main > /etc/apt/sources.list.d/docker.list

apt-get -y -qq update
add-apt-repository -y ppa:git-core/ppa > /dev/null 2>&1
add-apt-repository -y ppa:pi-rho/dev > /dev/null 2>&1

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
tree \
tmux-next \
docker-engine=1.13.1-0~ubuntu-trusty > /dev/null 2>&1


install_oh_my_zsh 'vagrant' $VAGRANT_HOME

echo "VAGRANT_REPOSITORY_FOLDER $VAGRANT_REPOSITORY_FOLDER"
! test -d "$VAGRANT_REPOSITORY_FOLDER"  && mkdir -p "$VAGRANT_REPOSITORY_FOLDER" && chown -R vagrant.vagrant "$VAGRANT_REPOSITORY_FOLDER"
echo "REPOSITORY_FOLDER $REPOSITORY_FOLDER"
echo "LOG_FOLDER $LOG_FOLDER"

echo "MAKING LOCAL DIRECTORY STRUCTURE"
exe rm -rf "$LOCAL_DIR"
exe mkdir -p "$BUILD_DIR"
exe mkdir -p "$BIN_DIR"

# collect all the files
exe cd "$BUILD_DIR"
# add check for local file, error checking, early exit and message if error
echo "Downloading Python"
exe curl -sq $PYTHON_DOWNLOAD_URL -o $PYTHON_DOWNLOAD_FILE
echo "Downloading Vertica"
exe curl -sq $VERTICA_DOWNLOAD_URL -o $VERTICA_DOWNLOAD_FILE
echo "installing vertica"
exe tar -xzf $VERTICA_DOWNLOAD_FILE

exe cp opt/vertica/bin/vsql "$BIN_DIR"
exe chmod a+x $BIN_DIR/vsql
exe mkdir -p /var/log/vertica && touch /var/log/vertica/rejected.log && touch /var/log/vertica/exceptions.log && chown -R vagrant /var/log/vertica
exe rm -rf opt

echo "compiling python source"
# install python TODO: find a ubuntu package for this
exe cd $BUILD_DIR
exe tar -xzf $PYTHON_DOWNLOAD_FILE
exe cd $PYTHON_SRC_DIR || exit 1
exe ./configure -q --prefix="$VAGRANT_HOME/.local" && make altinstall > /dev/null 2>&1

exe test -d Python-2.7.13 && rm -rf Python-2.7.13

exe mkdir -p /etc/simplereach
# config file for postgres
cat > /etc/simplereach/postgres.json  <<- 'EOF'
 {
   "database": "skycutter_development",
   "username": "postgres",
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
  "LOG_DIR": "/var/log",
  "host": "localhost",
  "database": "verticadb",
  "vertica_user": "dbadmin",
  "vertica_password": "",
  "vertica_port": "5433"
}
EOF


exe curl -qsL "https://github.com/docker/compose/releases/download/1.8.1/docker-compose-$(uname -s)-$(uname -m) -o $BIN_DIR/docker-compose"  > /dev/null 2>&1 && chmod a+x "$BIN_DIR/docker-compose"

# add vagrant to the docker group so it can access the docker daemon socket
exe usermod -aG docker vagrant

exe chown -R vagrant.vagrant $LOCAL_DIR

