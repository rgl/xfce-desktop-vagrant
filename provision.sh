#!/bin/bash
# abort this script on errors.
set -eux

# prevent apt-get et al from opening stdin.
# NB even with this, you'll still get some warnings that you can ignore:
#     dpkg-preconfigure: unable to re-open stdin: No such file or directory
export DEBIAN_FRONTEND=noninteractive

apt-get update

# install the desktop.
apt-get install -y ubuntu-desktop-minimal
#apt-get install -y xrdp
#apt-get install -y chromium-browser

# install useful tools.
apt-get install -y git-core meld
apt-get install -y --no-install-recommends httpie
apt-get install -y --no-install-recommends vim

# install Visual Studio Code.
apt-get install -y apt-transport-https # NB because VSC is installed from an https repo.
wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | apt-key add -
echo 'deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main' >/etc/apt/sources.list.d/vscode.list
apt-get update
apt-get install -y code

# set system configuration.
rm -f /{root,home/*}/.{profile,bashrc}
cp -v -r /vagrant/config/etc/* /etc

su vagrant -c bash <<'VAGRANT_EOF'
#!/bin/bash
# abort this script on errors.
set -eux

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
