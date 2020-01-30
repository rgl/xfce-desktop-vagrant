#!/bin/bash
set -eux

# install.
apt-get install -y xrdp

# copy the logo.
install /vagrant/xrdp-xfce-logo.bmp /usr/local/share/xrdp-xfce-logo.bmp

# configure.
# TODO switch to https://github.com/DiffSK/configobj/milestone/5 once 5.1.0 is released (it can handle ";" comments).
python3 <<'EOF'
sections = []

with open('/etc/xrdp/xrdp.ini', 'r') as f:
    section = []
    for l in f:
        line = l.rstrip()
        if line.startswith('['):
            if section:
                sections.append(section)
                section = []
        section.append(line)
    if section:
        sections.append(section)

with open('/etc/xrdp/xrdp.ini', 'w') as f:
    for section in sections:
        write_section = True
        if section[0] == '[Globals]':
            for n, line in enumerate(section):
                if line.startswith('ls_logo_filename='):
                    section[n] = 'ls_logo_filename=/usr/local/share/xrdp-xfce-logo.bmp'
        for line in section:
            # only show the Xorg session option.
            if line.startswith('name=') and line != 'name=Xorg':
                write_section = False
                break
        if write_section:
            for line in section:
                f.write(line)
                f.write("\n")
EOF

# restart the service to apply the new configuration.
systemctl restart xrdp
