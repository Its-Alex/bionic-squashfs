Vagrant.configure('2') do |config|
  config.vm.provider :virtualbox do |vb|
    vb.memory = 8192
  end

  config.vm.define :builder do |config|
    config.vm.box = 'ubuntu/bionic64'
    config.vm.hostname = 'builder'

    config.vm.synced_folder ".", "/vagrant", disabled: true
    config.vm.synced_folder './scripts', '/home/vagrant/scripts/'
    config.vm.synced_folder './output', '/home/vagrant/output/'
    config.vm.synced_folder './assets', '/home/vagrant/assets/'

    $script = <<SCRIPT
apt-get update -y

apt-get -y install \
    debootstrap \
    syslinux \
    isolinux \
    squashfs-tools \
    genisoimage \
    memtest86+
SCRIPT
    config.vm.provision "shell", inline: $script
  end
end
