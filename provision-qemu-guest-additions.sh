#!/bin/bash
set -eux
export DEBIAN_FRONTEND=noninteractive

# if nested virtualization is available, install kvm too.
if [ -n "$(grep ' vmx ' /proc/cpuinfo)" ]; then
    apt-get install -y qemu-kvm
    apt-get install -y sysfsutils
    systool -m kvm_intel -v
    # let the vagrant user manage kvm.
    usermod -aG kvm vagrant
fi
