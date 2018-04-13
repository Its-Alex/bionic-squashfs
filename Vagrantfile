# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure('2') do |config|
  config.vm.define :builder do |config|
    config.vm.box = 'ubuntu/bionic64'
    config.vm.hostname = 'builder'

    config.vm.synced_folder '.', '/vagrant'

    config.vm.provider :virtualbox do |vb|
      vb.memory = 8192
    end
  end
end
