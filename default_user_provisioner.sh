#!/bin/bash
# TODO: cleanup unneeded files
# figure out post_provision hook to install python packages in virtualenvs
echo "VAGRANT_REPOSITORY_FOLDER $VAGRANT_REPOSITORY_FOLDER"
echo "REPOSITORY_FOLDER $REPOSITORY_FOLDER"
echo "LOG_FOLDER $LOG_FOLDER"
echo "HOME $HOME"

export VERTICA_LOG_DIR=/var/log/vertica
export LOG_DIR=/var/log
export POSTGRES_USER=postgres
export NSQD_BROADCAST_ADDRESS=nsqd
export LOCAL_DIR=$HOME/.local
export BUILD_DIR="$LOCAL_DIR/build"
export BIN_DIR="$LOCAL_DIR/bin"
export PYTHON_EXECUTABLE="$BIN_DIR/python2.7"
export PIP_EXECUTABLE="$BIN_DIR/pip"
export VIRTUALENVWRAPPER_PYTHON=$PYTHON_EXECUTABLE
export VIRTUALENVWRAPPER_VIRTUALENV_ARGS='--no-site-packages'
export WORKON_HOME=$HOME/.virtualenvs
export PIP_VIRTUALENV_BASE=$WORKON_HOME
export PIP_RESPECT_VIRTUALENV=true
export PATH=$HOME/.local/bin:$PATH

function exe() { echo "\$ $@" ; "$@" ; }

touch $HOME/.ssh/config
chmod 600 $HOME/.ssh/config

cat << 'EOF' >> /home/vagrant/.ssh/config

StrictHostKeyChecking no

EOF

# install pip
exe cd $BUILD_DIR || exit 1
exe curl -sq https://bootstrap.pypa.io/get-pip.py -o get-pip.py

exe $PYTHON_EXECUTABLE get-pip.py --user
exe chmod a+x get-pip.py
$PIP_EXECUTABLE install --user virtualenvwrapper
exe source "$BIN_DIR/virtualenvwrapper.sh"

for var in $(env); do
    echo "$var"
done


#echo "installing virtualenvwrapper to .local"
# TODO: find all the requirements.txt files under projects and install them
# in virtualenvs with the project directory name

#test -d ~/.virtualenvs && rm -rf ~/.virtualenvs && echo "deleting old ~/.virtualenvs"
#/bin/mkdir ~/.virtualenvs && echo "~/.virtualenvs directory created"

exe cd "$VAGRANT_REPOSITORY_FOLDER/pyworkers-common"
exe mkvirtualenv --no-site-packages -p "$PYTHON_EXECUTABLE" "pyworkers-common" > /dev/null 2>&1
exe "$PIP_EXECUTABLE" install -r "$VAGRANT_REPOSITORY_FOLDER/pyworkers-common/requirements.txt" > /dev/null

exe cd "$VAGRANT_REPOSITORY_FOLDER"
exe mkvirtualenv --no-site-packages -p "$PYTHON_EXECUTABLE" "pyworkers-video-platform" > /dev/null 2>&1
exe workon pyworkers-video-platform

exe cd "$VAGRANT_REPOSITORY_FOLDER/pyworkers-video-platform/pyworkers-common"
exe "$PIP_EXECUTABLE" install -r requirements.txt

exe cd ../
exe "$PYTHON_EXECUTABLE" setup.py install
exe $PIP_EXECUTABLE install -r "$VAGRANT_REPOSITORY_FOLDER/pyworkers-video-platform/requirements.dev.txt" > /dev/null 2>&1

