#!/bin/bash
# abort this script on errors.
set -eux

# prevent apt-get et al from opening stdin.
# NB even with this, you'll still get some warnings that you can ignore:
#     dpkg-preconfigure: unable to re-open stdin: No such file or directory
export DEBIAN_FRONTEND=noninteractive

apt-get update

apt-get install -y xfce4 lightdm lightdm-gtk-greeter
apt-get install -y xfce4-terminal
apt-get install -y xfce4-whiskermenu-plugin
apt-get install -y xfce4-taskmanager
apt-get install -y menulibre
apt-get install -y firefox
apt-get install -y qemu-utils
apt-get install -y git-core meld
apt-get install -y --no-install-recommends httpie
apt-get install -y --no-install-recommends vim

# install Visual Studio Code.
wget -q -O/tmp/vscode_amd64.deb 'https://go.microsoft.com/fwlink/?LinkID=760868'
dpkg -i /tmp/vscode_amd64.deb
rm /tmp/vscode_amd64.deb

# install VirtualBox.
# see https://www.virtualbox.org/wiki/Linux_Downloads
wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | apt-key add -
wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | apt-key add -
echo 'deb http://download.virtualbox.org/virtualbox/debian xenial contrib' >/etc/apt/sources.list.d/virtualbox.list
apt-get update
apt-get install -y virtualbox-5.1

# install Packer.
apt-get install -y unzip
packer_version=0.12.2
wget -q -O/tmp/packer_${packer_version}_linux_amd64.zip https://releases.hashicorp.com/packer/${packer_version}/packer_${packer_version}_linux_amd64.zip
unzip /tmp/packer_${packer_version}_linux_amd64.zip -d /usr/local/bin

# install Vagrant.
vagrant_version=1.9.1
wget -q -O/tmp/vagrant_${vagrant_version}_x86_64.deb https://releases.hashicorp.com/vagrant/${vagrant_version}/vagrant_${vagrant_version}_x86_64.deb
dpkg -i /tmp/vagrant_${vagrant_version}_x86_64.deb
rm /tmp/vagrant_${vagrant_version}_x86_64.deb

# set system configuration.
cp -v -r /vagrant/config/etc/* /etc

su vagrant -c bash <<'VAGRANT_EOF'
#!/bin/bash
# abort this script on errors.
set -eux

# set user configuration.
mkdir -p .config
cp -r /vagrant/config/dotconfig/* .config
find .config -type d -exec chmod 700 {} \;
find .config -type f -exec chmod 600 {} \;

# configure git.
# see http://stackoverflow.com/a/12492094/477532
git config --global user.name 'Rui Lopes'
git config --global user.email 'rgl@ruilopes.com'
git config --global push.default simple
git config --global diff.guitool meld
git config --global difftool.meld.path meld
git config --global difftool.meld.cmd 'meld "$LOCAL" "$REMOTE"'
git config --global merge.tool meld
git config --global mergetool.meld.path meld
git config --global mergetool.meld.cmd 'meld --diff "$LOCAL" "$BASE" "$REMOTE" --output "$MERGED"'
#git config --list --show-origin

# create SSH keypair and dump the public key.
ssh-keygen -f ~/.ssh/id_rsa -t rsa -N ""
VAGRANT_EOF

apt-get remove -y --purge xscreensaver
apt-get autoremove -y --purge
