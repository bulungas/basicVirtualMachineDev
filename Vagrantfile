# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "chef/centos-6.6"
  config.vm.box_check_update = false
  config.vbguest.auto_update = false
  config.vbguest.auto_reboot = false
  config.vm.network "private_network", ip: "192.168.56.13"
  config.vm.provider "virtualbox" do |vb|
        # Display the VirtualBox GUI when booting the machine
        vb.gui = false
        # Customize the amount of memory on the VM:
        vb.memory = "200"
    end
  
  config.vm.synced_folder "../proyecto", "/www/www.proyecto.local.com", disabled: (not FileTest::directory?("../proyecto"))  


  config.vm.provision :shell do |shell|
    shell.path = "vagrant/setup.sh"
  end  
  config.vm.provision "puppet", run: "always" do |puppet|
    puppet.manifests_path = "puppet/manifests"
    puppet.manifest_file = "site.pp"
  end
  #config.vm.provision :shell do |s|
  #  s.inline = "cat /vagrant/vagrant/DB/schema/*.sql /vagrant/vagrant/DB/data/*.sql | mysql -u root -f"
  #end
end