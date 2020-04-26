#!/bin/bash
set -euxo pipefail

# disable telemetry.
echo 'export POWERSHELL_TELEMETRY_OPTOUT=1' >/etc/profile.d/disable-powershell-telemetry.sh
echo 'export DOTNET_CLI_TELEMETRY_OPTOUT=1' >/etc/profile.d/disable-dotnet-cli-telemetry.sh
source /etc/profile.d/disable-powershell-telemetry.sh
source /etc/profile.d/disable-dotnet-cli-telemetry.sh

# install.
powershell_version=7.0.0
powershell_url="https://github.com/PowerShell/PowerShell/releases/download/v${powershell_version}/powershell-${powershell_version}-linux-x64.tar.gz"
powershell_filename="$(basename $powershell_url)"
wget -q $powershell_url
install -d /opt/powershell
tar xf $powershell_filename -C /opt/powershell
rm $powershell_filename
ln -s /opt/powershell/pwsh /usr/bin
