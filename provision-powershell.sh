#!/bin/bash
set -euxo pipefail

powershell_version=7.0.0
powershell_url="https://github.com/PowerShell/PowerShell/releases/download/v${powershell_version}/powershell-${powershell_version}-linux-x64.tar.gz"
powershell_filename="$(basename $powershell_url)"
wget -q $powershell_url
install -d /opt/powershell
tar xf $powershell_filename -C /opt/powershell
rm $powershell_filename
ln -s /opt/powershell/pwsh /usr/bin
