#!/bin/bash
set -eux

# install ansible from ppa.
# NB use apt-cache madison ansible to known the available versions.
#    at the time of writting this installed ansible 2.9.0-1ppa~bionic.
# NB this uses python2. python3 is not yet provided as a ppa
#    (there's an open issue at https://github.com/ansible/ansible/issues/57342).
# see https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#latest-releases-via-apt-ubuntu
apt-get install -y software-properties-common
apt-add-repository --yes --update ppa:ansible/ansible
apt-get install -y ansible
ansible --version
ansible -m ping localhost

# install the ansible shell completion helpers.
apt-get install -y python-argcomplete
activate-global-python-argcomplete
