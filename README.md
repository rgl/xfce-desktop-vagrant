Install the [Ubuntu 18.04 Base Box](https://github.com/rgl/ubuntu-vagrant).

Install the required plugins:

```bash
vagrant plugin install vagrant-reload
```

Run `vagrant up --provider=libvirt` to launch with libvirt (qemu-kvm).

Run `vagrant up --provider=virtualbox` to launch with VirtualBox.

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
