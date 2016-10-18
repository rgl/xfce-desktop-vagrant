Vagrant.configure(2) do |config|
  config.vm.box = 'ubuntu-16.04-amd64'

  config.vm.hostname = 'xfce-desktop'

  config.vm.provider 'virtualbox' do |vb|
    vb.gui = true
    vb.linked_clone = true
    vb.memory = 4096
    vb.customize ["modifyvm", :id, "--vram", 64]
    vb.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
    vb.customize ["modifyvm", :id, "--draganddrop", "bidirectional"]
    vb.customize ['modifyvm', :id, '--cableconnected1', 'on']
    vb.customize ["storageattach", :id, "--storagectl", "IDE Controller", "--device", 0, "--port", 1, "--type", "dvddrive", "--medium", "additions"]
  end

  config.vm.provision 'shell', path: 'provision.sh'
  config.vm.provision :reload
  config.vm.provision 'shell', path: 'provision-virtualbox-guest-additions.sh'
  config.vm.provision :reload
end
