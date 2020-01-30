Install the [Ubuntu 18.04 Base Box](https://github.com/rgl/ubuntu-vagrant).

Install the required plugins:

```bash
vagrant plugin install vagrant-reload
```

Run `vagrant up --provider=libvirt` to launch with libvirt (qemu-kvm).

Run `vagrant up --provider=virtualbox` to launch with VirtualBox.
