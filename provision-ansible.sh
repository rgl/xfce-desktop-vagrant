#!/bin/bash
set -eux

ansible_version='2.9.7'         # see https://pypi.org/project/ansible/
ansible_lint_version='4.2.0'    # see https://pypi.org/project/ansible-lint/

# install ansible into the /opt/ansible venv.
# see https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-ansible-with-pip
apt-get install -y --no-install-recommends python3-pip python3-venv
python3 -m venv /opt/ansible
source /opt/ansible/bin/activate
# NB this pip install will display several "error: invalid command 'bdist_wheel'"
#    messages, those can be ignored.
python3 -m pip install ansible==$ansible_version ansible-lint==$ansible_lint_version
ansible --version
ansible -m ping localhost

# install the ansible shell completion helpers.
apt-get install -y python3-argcomplete
activate-global-python-argcomplete3
