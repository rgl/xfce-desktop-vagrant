#!/bin/bash
set -eux
if [ -n "$(lspci | grep VirtualBox)" ]; then
    bash /vagrant/provision-virtualbox-guest-additions.sh
else
    bash /vagrant/provision-qemu-guest-additions.sh
fi
