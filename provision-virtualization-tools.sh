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

# install jq.
apt-get install -y jq

# install unzip.
apt-get install -y unzip

# install libvirt et al.
apt-get install -y virt-manager
# configure the security_driver to prevent errors alike (when using terraform):
#   Could not open '/var/lib/libvirt/images/terraform_example_root.img': Permission denied'
sed -i -E 's,#?(security_driver)\s*=.*,\1 = "none",g' /etc/libvirt/qemu.conf
systemctl restart libvirtd
adduser --quiet --disabled-password --gecos "vagrant" vagrant
# set password
echo "vagrant:vagrant" | chpasswd
# let the vagrant user manage libvirtd.
# see /usr/share/polkit-1/rules.d/60-libvirt.rules
usermod -aG libvirt vagrant

# install terraform.
terraform_version=0.12.24
terraform_url="https://releases.hashicorp.com/terraform/$terraform_version/terraform_${terraform_version}_linux_amd64.zip"
terraform_filename="$(basename $terraform_url)"
wget -q $terraform_url
unzip $terraform_filename
install terraform /usr/local/bin
rm terraform $terraform_filename
# install the libvirt provider.
terraform_libvirt_provider_url='https://github.com/dmacvicar/terraform-provider-libvirt/releases/download/v0.6.2/terraform-provider-libvirt-0.6.2+git.1585292411.8cbe9ad0.Ubuntu_18.04.amd64.tar.gz'
terraform_libvirt_provider_filename="/tmp/$(basename $terraform_libvirt_provider_url)"
wget -qO$terraform_libvirt_provider_filename $terraform_libvirt_provider_url
su vagrant -c bash <<VAGRANT_EOF
#!/bin/bash
set -euxo pipefail
cd ~
tar xf $terraform_libvirt_provider_filename
install -d ~/.terraform.d/plugins/linux_amd64
install terraform-provider-libvirt ~/.terraform.d/plugins/linux_amd64/
rm terraform-provider-libvirt
VAGRANT_EOF
rm $terraform_libvirt_provider_filename

# install Packer.
apt-get install -y unzip
packer_version=1.6.6
wget -q -O/tmp/packer_${packer_version}_linux_amd64.zip https://releases.hashicorp.com/packer/${packer_version}/packer_${packer_version}_linux_amd64.zip
yes | unzip /tmp/packer_${packer_version}_linux_amd64.zip -d /usr/local/bin
# install useful packer plugins.
wget -q -O/tmp/packer-provisioner-windows-update-linux.tgz https://github.com/rgl/packer-provisioner-windows-update/releases/download/v0.9.0/packer-provisioner-windows-update-linux.tgz
tar xf /tmp/packer-provisioner-windows-update-linux.tgz -C /usr/local/bin
chmod +x /usr/local/bin/packer-provisioner-windows-update
rm /tmp/packer-provisioner-windows-update-linux.tgz

# install Vagrant.
vagrant_version=2.2.19
wget -q -O/tmp/vagrant_${vagrant_version}_x86_64.deb https://releases.hashicorp.com/vagrant/${vagrant_version}/vagrant_${vagrant_version}_x86_64.deb
dpkg -i /tmp/vagrant_${vagrant_version}_x86_64.deb
rm /tmp/vagrant_${vagrant_version}_x86_64.deb
# install useful vagrant plugins.
apt-get install -y libvirt-dev gcc make
su vagrant -c bash <<'VAGRANT_EOF'
#!/bin/bash
set -eux
cd ~
vagrant plugin install vagrant-reload
CONFIGURE_ARGS='with-libvirt-include=/usr/include/libvirt with-libvirt-lib=/usr/lib' \
    vagrant plugin install vagrant-libvirt
vagrant plugin install vagrant-windows-update
VAGRANT_EOF
# add support for smb shared folders.
# see https://github.com/hashicorp/vagrant/pull/9948
pushd /opt/vagrant/embedded/gems/$vagrant_version/gems/vagrant-$vagrant_version
wget -q https://github.com/hashicorp/vagrant/commit/ed7139fa1e896d0b84ed32180b72a647bf9f37eb.patch
patch -p1 <ed7139fa1e896d0b84ed32180b72a647bf9f37eb.patch
rm ed7139fa1e896d0b84ed32180b72a647bf9f37eb.patch
popd
apt-get install -y samba smbclient
smbpasswd -a -s vagrant <<'EOF'
vagrant
vagrant
EOF
