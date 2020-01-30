#!/bin/bash
# abort this script on errors.
set -eux

# prevent apt-get et al from opening stdin.
# NB even with this, you'll still get some warnings that you can ignore:
#     dpkg-preconfigure: unable to re-open stdin: No such file or directory
export DEBIAN_FRONTEND=noninteractive

# install iso creation tool.
# NB xorriso is compatible with genisoimage and mkisofs and is also available in msys2 (windows).
apt-get install -y xorriso

# install the iso-info tool.
# NB iso-info is also available in msys2 (windows) as provided by the mingw-w64-x86_64-libcdio package.
apt-get install -y libcdio-utils

# install qemu tools.
apt-get install -y qemu-utils

# install VirtualBox.
# see https://www.virtualbox.org/wiki/Linux_Downloads
wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | apt-key add -
wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | apt-key add -
echo "deb http://download.virtualbox.org/virtualbox/debian $(lsb_release -sc) contrib" >/etc/apt/sources.list.d/virtualbox.list
apt-get update
apt-get install -y virtualbox-6.0

# install libvirt et al.
apt-get install -y virt-manager
# let the vagrant user manage libvirtd.
# see /usr/share/polkit-1/rules.d/60-libvirt.rules
usermod -aG libvirt vagrant

# install Packer.
apt-get install -y unzip
packer_version=1.4.5
wget -q -O/tmp/packer_${packer_version}_linux_amd64.zip https://releases.hashicorp.com/packer/${packer_version}/packer_${packer_version}_linux_amd64.zip
unzip /tmp/packer_${packer_version}_linux_amd64.zip -d /usr/local/bin
# install useful packer plugins.
wget -q -O/tmp/packer-provisioner-windows-update-linux.tgz https://github.com/rgl/packer-provisioner-windows-update/releases/download/v0.8.0/packer-provisioner-windows-update-linux.tgz
tar xf /tmp/packer-provisioner-windows-update-linux.tgz -C /usr/local/bin
chmod +x /usr/local/bin/packer-provisioner-windows-update
rm /tmp/packer-provisioner-windows-update-linux.tgz

# install Vagrant.
vagrant_version=2.2.6
wget -q -O/tmp/vagrant_${vagrant_version}_x86_64.deb https://releases.hashicorp.com/vagrant/${vagrant_version}/vagrant_${vagrant_version}_x86_64.deb
dpkg -i /tmp/vagrant_${vagrant_version}_x86_64.deb
rm /tmp/vagrant_${vagrant_version}_x86_64.deb
# install useful vagrant plugins.
apt-get install -y libvirt-dev
su vagrant -c bash <<'VAGRANT_EOF'
#!/bin/bash
set -eux
cd ~
vagrant plugin install vagrant-reload
CONFIGURE_ARGS='with-libvirt-include=/usr/include/libvirt with-libvirt-lib=/usr/lib' \
    vagrant plugin install vagrant-libvirt
vagrant plugin install vagrant-windows-update
VAGRANT_EOF
