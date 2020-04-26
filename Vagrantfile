def which(cmd)
  exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
  ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
    exts.each do |ext|
      exe = File.join(path, "#{cmd}#{ext}")
      return exe if File.executable?(exe) && !File.directory?(exe)
    end
  end
  nil
end

Vagrant.configure(2) do |config|
  config.vm.box = 'ubuntu-18.04-amd64'

  config.vm.hostname = 'xfce-desktop'

  config.vm.provider "libvirt" do |lv, config|
    lv.memory = 4096
    lv.cpus = 4
    lv.cpu_mode = "host-passthrough"
    lv.nested = true # nested virtualization.
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
    if which 'VBoxManage'
      # NB if this fails on Ubuntu, you should install the virtualbox-guest-additions-iso package.
      guest_additions_path = `VBoxManage list systemproperties`.lines.grep(/^Default Guest Additions ISO:/).first.split(':', 2).last.strip
      vb.customize ["storageattach", :id, "--storagectl", "SATA Controller", "--device", 0, "--port", 1, "--type", "dvddrive", "--medium", guest_additions_path]
    end
  end

  # TODO Evaluate the enhanced session mode at https://wiki.archlinux.org/index.php/Hyper-V
  config.vm.provider 'hyperv' do |hv, override|
    #hv.vmname = "#{File.basename(File.dirname(File.dirname(__FILE__)))}"
    hv.linked_clone = true
    hv.memory = 4096
    hv.cpus = 4
    hv.enable_virtualization_extensions = true # nested virtualization.
    hv.vlan_id = ENV['HYPERV_VLAN_ID']
    # see https://github.com/hashicorp/vagrant/issues/7915
    # see https://github.com/hashicorp/vagrant/blob/10faa599e7c10541f8b7acf2f8a23727d4d44b6e/plugins/providers/hyperv/action/configure.rb#L21-L35
    override.vm.network :private_network, bridge: ENV['HYPERV_SWITCH_NAME'] if ENV['HYPERV_SWITCH_NAME']
    override.vm.synced_folder '.', '/vagrant',
      type: 'smb',
      smb_username: ENV['VAGRANT_SMB_USERNAME'] || ENV['USER'],
      smb_password: ENV['VAGRANT_SMB_PASSWORD']
  end

  config.vm.provision 'shell', path: 'provision.sh'
  config.vm.provision :reload
  config.vm.provision 'shell', path: 'provision-guest-additions.sh'
  config.vm.provision :reload
  config.vm.provision 'shell', path: 'provision-xrdp.sh'
  config.vm.provision 'shell', path: 'provision-ansible.sh'
  config.vm.provision 'shell', path: 'provision-powershell.sh'
  config.vm.provision 'shell', path: 'provision-nfs-server.sh'
  config.vm.provision 'shell', path: 'provision-virtualization-tools.sh'
  config.vm.provision :reload
end
