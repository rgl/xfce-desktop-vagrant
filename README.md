# Usage

Install the [Ubuntu 18.04 Base Box](https://github.com/rgl/ubuntu-vagrant).

Install the required plugins:

```bash
vagrant plugin install vagrant-reload
```

## libvirt (qemu-kvm)

To launch with libvirt (qemu-kvm) use:

```bash
vagrant up --provider=libvirt
```

## VirtualBox

To launch with VirtualBox use:

```bash
vagrant up --provider=virtualbox
```

## Hyper-V

To launch with Hyper-V use:

**NB** You will need Administrative privileges to create the SMB share.

**NB** You will need to be in the `Hyper-V Administrators` local group to be able to access Hyper-V.

```bash
cat >secrets.sh <<'EOF'
# set this value when you need to set the VM Switch Name.
export HYPERV_SWITCH_NAME='Default Switch'
# set this value when you need to set the VM VLAN ID.
export HYPERV_VLAN_ID=''
# set the credentials that the guest will use
# to connect to this host smb share.
# NB you should create a new local user named _vagrant_share
#    and use that one here instead of your user credentials.
# NB it would be nice for this user to have its credentials
#    automatically rotated, if you implement that feature,
#    let me known!
export VAGRANT_SMB_USERNAME='_vagrant_share'
export VAGRANT_SMB_PASSWORD=''
# remove the virtual switch from the windows firewall.
# NB execute if the VM fails to obtain an IP address from DHCP.
PowerShell -Command 'Set-NetFirewallProfile -DisabledInterfaceAliases (Get-NetAdapter -name 'vEthernet*' | Where-Object {$_.ifIndex}).InterfaceAlias'
# grant $VAGRANT_SMB_USERNAME full permissions to the
# current directory.
# NB you must first install the Carbon PowerShell module
#    with choco install -y carbon.
PowerShell -Command 'Import-Module Carbon; Grant-Permission . $env:VAGRANT_SMB_USERNAME FullControl'
EOF
source secrets.sh
vagrant up --provider=hyperv
```

## Remote Desktop

You can use a Remote Desktop Protocol (RDP) client to access this machine.
For example, with [xfreerdp](https://github.com/FreeRDP/FreeRDP):

```bash
sudo apt-get install -y freerdp2-x11
# use vagrant:
vagrant rdp
# or use xfreerdp:
# NB you CANNOT be logged in at the graphical terminal for this to work.
winrm_config="$(vagrant winrm-config)"
rdp_host="$(awk '/ RDPHostName /{print $2}' <<<"$winrm_config"):$(awk '/ RDPPort /{print $2}' <<<"$winrm_config")"
rdp_username="$(awk '/ User /{print $2}' <<<"$winrm_config")"
rdp_password="$(awk '/ Password /{print $2}' <<<"$winrm_config")"
xfreerdp "/v:$rdp_host" "/u:$rdp_username" "/p:$rdp_password" /size:1440x900 +clipboard
```
