####################################
### Load Configuration Variables
####################################
require 'yaml'
vconfig = YAML::load_file("config/config.yaml")

# Handle vhosts
vhosts = ""
vconfig['vhosts'].each_with_index do |v, k|
	vhosts = vhosts + "<VirtualHost *:80>\n"
	v.each_with_index do |val, key|
		vhosts = vhosts + "\t" + val.join(' ') + "\n"
	end
	vhosts = vhosts + "</VirtualHost>\n"
end

####################################
### Running Vagrant
####################################
Vagrant.configure("2") do |config|
	config.vagrant.host = :detect
	config.ssh.shell = vconfig['vagrant']['ssh_shell']
	config.ssh.username = vconfig['vagrant']['ssh_username']
	config.ssh.keep_alive = true

	####################################
	### Machine Setup
	####################################
	config.vm.box = vconfig['vagrant']['box']
	config.vm.box_url = vconfig['vagrant']['box_url']
	config.vm.network "private_network", ip: vconfig['vagrant']['box_ip']
	config.vm.hostname = vconfig['vagrant']['vm_hostname']
	config.vm.network "forwarded_port", guest: 80, host: vconfig['vagrant']['box_port']
	config.vm.network "forwarded_port", guest: 3306, host: vconfig['mysql']['port']
	config.vm.synced_folder vconfig['vagrant']['vm_webroot'], vconfig['vagrant']['vm_docroot'], :owner => "vagrant", :group => "www-data", :mount_options => ["dmode=777","fmode=777"]
  
	####################################
	### VirtualBox Provider
	####################################
	config.vm.provider "virtualbox" do |virtualbox|
		virtualbox.customize ["modifyvm", :id, "--cpuexecutioncap", vconfig['vagrant']['vm_cpu']]
		virtualbox.customize ["modifyvm", :id, "--name", vconfig['vagrant']['vm_name']]
		virtualbox.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
		virtualbox.customize ["modifyvm", :id, "--memory", vconfig['vagrant']['vm_memory']]
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
			"ssh_username" => vconfig['vagrant']['ssh_username'],
			"fqdn" => vconfig['vagrant']['vm_hostname'],
			"syspackages" => vconfig['syspackages'].join(','),
			"phpmodules" => vconfig['phpmodules'].join(','),
			"apachemodules" => vconfig['apachemodules'].join(','),
			"vhosts" => vhosts,
			"xdebug" => vconfig['xdebug'].join("\n")+"\n",
			"password" => vconfig['mysql']['password'],
		}
		puppet.options = "--verbose"
		puppet.manifests_path = "config/puppet/manifests"
		puppet.manifest_file = "default.pp"
		#puppet.module_path = "config/puppet/modules"
	end

	####################################
	### Run SQL
	####################################
	config.vm.provision "shell",
    inline: "mysql -uroot -p"+vconfig['mysql']['password']+" < '/etc/mysql/remote.sql'"
	
	####################################
	### Ready
	####################################
	config.vm.provision "shell",
    inline: "echo ###########################\n# It's Ready!\n###########################"
end