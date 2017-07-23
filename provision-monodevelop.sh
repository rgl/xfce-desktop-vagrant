#!/bin/bash
# abort this script on errors.
set -eux

# prevent apt-get et al from opening stdin.
# NB even with this, you'll still get some warnings that you can ignore:
#     dpkg-preconfigure: unable to re-open stdin: No such file or directory
export DEBIAN_FRONTEND=noninteractive

# install the mono repository.
# see http://www.mono-project.com/download/#download-lin
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
echo "deb http://download.mono-project.com/repo/ubuntu $(lsb_release -sc) main" >/etc/apt/sources.list.d/mono-official.list
apt-get update

# install mono.
apt-get install -y mono-devel
mono --version

# install monodevelop.
# see http://www.monodevelop.com/download/linux/
apt-get install -y software-properties-common
add-apt-repository -y ppa:alexlarsson/flatpak
apt-get update
apt-get install -y flatpak
su vagrant -c 'flatpak install -y --user --from https://download.mono-project.com/repo/monodevelop.flatpakref'
su vagrant -c 'flatpak list'

# configure mono to use the legacy tls provider.
# NB this is needed to workaround a nuget restore problem (when restoring inside monodevelop):
#       https://api.nuget.org/v3/index.json: Unable to load the service index for source https://api.nuget.org/v3/index.json.
#       An error occurred while sending the request
#       Error: SecureChannelFailure (Object reference not set to an instance of an object)
#       Object reference not set to an instance of an object
echo 'export MONO_TLS_PROVIDER=legacy' >/etc/profile.d/mono.sh
