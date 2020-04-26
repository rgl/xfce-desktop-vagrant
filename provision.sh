#!/bin/bash
# abort this script on errors.
set -eux

# prevent apt-get et al from opening stdin.
# NB even with this, you'll still get some warnings that you can ignore:
#     dpkg-preconfigure: unable to re-open stdin: No such file or directory
export DEBIAN_FRONTEND=noninteractive

apt-get update

# install the desktop.
apt-get install -y --no-install-recommends \
    xorg \
    xserver-xorg-video-qxl \
    xserver-xorg-video-fbdev \
    xserver-xorg-video-vmware \
    xfce4 \
    xfce4-terminal \
    lightdm \
    lightdm-gtk-greeter \
    xfce4-whiskermenu-plugin \
    xfce4-taskmanager \
    menulibre \
    firefox

# install useful tools.
apt-get install -y --no-install-recommends git-core meld
apt-get install -y --no-install-recommends httpie
apt-get install -y --no-install-recommends vim

# install Visual Studio Code.
apt-get install -y --no-install-recommends gnupg apt-transport-https # NB because VSC is installed from an https repo.
wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | apt-key add -
echo 'deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main' >/etc/apt/sources.list.d/vscode.list
apt-get update
apt-get install -y code
su vagrant -c bash <<'VAGRANT_EOF'
#!/bin/bash
set -eux
# install extensions.
code_extensions=(
    'hookyqr.beautify'
    'dotjoshjohnson.xml'
    'docsmsft.docs-authoring-pack'
    'ms-vscode-remote.remote-ssh'
    'ms-vscode.powershell'
    'ms-dotnettools.csharp'
    'ms-vscode.go'
    'ms-python.python'
    'mauve.terraform'
    'ms-azuretools.vscode-docker'
    'zamerick.vscode-caddyfile-syntax'
)
for name in ${code_extensions[@]}; do
    code --install-extension $name
done
# configure the settings.
install -d ~/.config/Code/User
cat >~/.config/Code/User/settings.json <<'EOF'
{
    "files.associations": {
        "Vagrantfile": "ruby"
    }
}
EOF
VAGRANT_EOF

# set system configuration.
rm -f /{root,home/*}/.{profile,bashrc}
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
