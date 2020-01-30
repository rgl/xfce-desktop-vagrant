Vagrant.configure(2) do |config|
  config.vm.box = 'ubuntu-18.04-amd64'

  config.vm.hostname = 'xfce-desktop'

  config.vm.provider "libvirt" do |lv, config|
    lv.memory = 4096
    lv.cpus = 4
    lv.cpu_mode = "host-passthrough"
    lv.nested = true
    lv.keymap = "pt"
    config.vm.synced_folder '.', '/vagrant', type: 'nfs'
  end

  config.vm.provider 'virtualbox' do |vb|
    vb.gui = true
    vb.linked_clone = true
    vb.memory = 4096
    vb.cpus = 4
    vb.customize ["modifyvm", :id, "--vram", 64]
    vb.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
    vb.customize ["modifyvm", :id, "--draganddrop", "bidirectional"]
    # NB if this fails on Ubuntu, you should install the virtualbox-guest-additions-iso package.
    default_guest_additions_path = "/usr/share/virtualbox/VBoxGuestAdditions.iso"
    guest_additions_path = File.file?(default_guest_additions_path) ? default_guest_additions_path : "additions"
    vb.customize ["storageattach", :id, "--storagectl", "SATA Controller", "--device", 0, "--port", 1, "--type", "dvddrive", "--medium", guest_additions_path]
  end

  config.vm.provision 'shell', path: 'provision.sh'
  config.vm.provision :reload
  config.vm.provision 'shell', path: 'provision-guest-additions.sh'
  config.vm.provision :reload
  config.vm.provision 'shell', path: 'provision-xrdp.sh'
  config.vm.provision 'shell', path: 'provision-ansible.sh'
  config.vm.provision 'shell', path: 'provision-virtualization-tools.sh'
  config.vm.provision 'shell', path: 'provision-monodevelop.sh'
  config.vm.provision :reload
end
