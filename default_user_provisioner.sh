# TODO: cleanup unneeded files
# figure out post_provision hook to install python packages in virtualenvs

touch ~/.ssh/config
chmod 600 /home/vagrant/.ssh/config

cat << 'EOF' >> /home/vagrant/.ssh/config

StrictHostKeyChecking no

EOF

mkdir -p ~/.local/bin
# install pip
cd ~/.simplereach/build
echo "Downloading Pip"
wget -q https://bootstrap.pypa.io/get-pip.py

echo "installing pip source"
chmod a+x get-pip.py
/usr/local/bin/python2.7 get-pip.py --user

echo "installing virtualenvwrapper to .local"
~/.local/bin/pip install --user virtualenvwrapper
export PATH=~/.local/bin:$PATH
source ~/.local/bin/virtualenvwrapper.sh
# TODO: find all the requirements.txt files under projects and install them
# in virtualenvs with the project directory name
test -d ~/.virtualenvs && mkdir ~/.virtualenvs
/bin/mkdir ~/.virtualenvs
export PYTHONPATH=""
mkvirtualenv -p /usr/local/bin/python2.7 pyworkers-common

mkvirtualenv -p /usr/local/bin/python2.7 pyworkers-video-platform
workon pyworkers-video-platform

# install a lot of commonly used packages so they're cached when a developer logs
# in and starts working on her repository
pip install -r /simplereach/development-environment/requirements.txt > /dev/null 2>&1
pip install -r /simplereach/pyworkers-video-platform/pyworkers-common/requirements.txt > /dev/null 2>&1
pip install -r /simplereach/pyworkers-video-platform/requirements.txt > /dev/null 2>&1
pip install -r /simplereach/pyworkers-video-platform/requirements.dev.txt > /dev/null 2>&1


# if there's an existing key don't clobber it
cat /dev/zero | /usr/bin/ssh-keygen -q -N "" -f  ~/.ssh/id_rsa > /dev/null
echo "IMPORTANT: install this key on your github account"
echo "-------------------------------------------------------"
cat ~/.ssh/id_rsa.pub

