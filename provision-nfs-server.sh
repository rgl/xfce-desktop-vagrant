#!/bin/bash
set -euxo pipefail

#
# provision the NFS server.
# see exports(5).

apt-get install -y nfs-kernel-server

# dump the supported nfs versions.
cat /proc/fs/nfsd/versions | tr ' ' "\n" | grep '^+' | tr '+' 'v'

# test access to the NFS server using NFSv3 (UDP and TCP) and NFSv4 (TCP).
showmount -e localhost
rpcinfo -u localhost nfs 3
rpcinfo -t localhost nfs 3
rpcinfo -t localhost nfs 4
