####################################
### Configuration Variables
####################################
box = "precise32"
box_url = "http://files.vagrantup.com/precise32.box"
box_port = 8080
box_ip = "10.0.0.123"
ssh_shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"
ssh_username = "vagrant"
vm_name = "cptserver"
vm_memory = "512"
vm_cpu = "50"
webroot = "www"
vm_hostname = "localhost"

####################################
### Running Vagrant
####################################
Vagrant.configure("2") do |config|
	config.vagrant.host = :detect
	config.ssh.shell = ssh_shell
	config.ssh.username = ssh_username
	config.ssh.keep_alive = true
	config.vm.box = box
	config.vm.box_url = box_url
	config.vm.network "private_network", ip: box_ip
	config.vm.hostname = vm_hostname
	config.vm.network "forwarded_port", guest: 80, host: box_port
	config.vm.synced_folder webroot, "/var/www", :owner => "vagrant", :group => "www-data", :mount_options => ["dmode=777","fmode=777"]
  
	####################################
	### VirtualBox Provider
	####################################
	config.vm.provider "virtualbox" do |virtualbox|
		virtualbox.customize ["modifyvm", :id, "--cpuexecutioncap", vm_cpu]
		virtualbox.customize ["modifyvm", :id, "--name", vm_name]
		virtualbox.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
		virtualbox.customize ["modifyvm", :id, "--memory", vm_memory]
		virtualbox.customize ["modifyvm", :id, "--rtcuseutc", "on"]
		virtualbox.customize ["setextradata", :id, "--VBoxInternal2/SharedFoldersEnableSymlinksCreate/v-root", "1"]
	end

	####################################
	### Shell Provisioning
	####################################
	config.vm.provision "shell" do |s|
		s.path = "config/shell/default.sh"
	end

	####################################
	### Puppet Provisioning
	####################################
	config.vm.provision "puppet" do |puppet|
		puppet.facter = {
			"ssh_username" => ssh_username,
			"fqdn" => config.vm.hostname
		}
		puppet.options = "--verbose --debug"
		puppet.manifests_path = "config/puppet/manifests"
		puppet.manifest_file = "default.pp"
		puppet.module_path = "config/puppet/modules"
	end
end