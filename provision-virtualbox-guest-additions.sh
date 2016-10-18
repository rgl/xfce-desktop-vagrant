#!/bin/bash
set -eux
mount /dev/sr0 /mnt
/mnt/VBoxLinuxAdditions.run
eject /dev/sr0
