####################################
### Load Configuration Variables
####################################
require 'yaml'
$vconfig = YAML::load_file("config/config.yaml")

# Handle directory
def getDirectory(directory, tabs)

	if tabs == 2
		tabs = "\t"
	else
		tabs = ""
	end

	rewrite = "\n\t"+tabs+"<Directory "+directory+">\n"
	$vconfig['directory'].each_with_index do |val, key|
		rewrite = rewrite + "\t\t"+ tabs + val + "\n"
	end
	rewrite = rewrite+"\t"+tabs+"</Directory>\n"
	return rewrite
end

# Handle email
email = ""
$vconfig['email'].each do |k, v|
	email = email+k+"="+v+"\n"
end

# Handle vhosts
vhosts = ""
$vconfig['vhosts'].each_with_index do |v, k|
	vhosts = vhosts + "<VirtualHost *:80>\n" + getDirectory(v['DocumentRoot'],1) + "\n"
	v.each_with_index do |val, key|
		vhosts = vhosts + "\t" + val.join(' ') + "\n"
	end
	vhosts = vhosts + "\n</VirtualHost>\n\n"
end

# Handle vhostsssl
vhostsssl = "<IfModule mod_ssl.c>\n\n"
$vconfig['vhosts'].each_with_index do |v, k|
	vhostsssl = vhostsssl + "\t<VirtualHost *:443>\n" + getDirectory(v['DocumentRoot'],2) + "\n"
	v.each_with_index do |val, key|
		vhostsssl = vhostsssl + "\t\t" + val.join(' ') + "\n"
	end
	vhostsssl = vhostsssl + "\n\t\tErrorLog ${APACHE_LOG_DIR}/error.log\n\t\tCustomLog ${APACHE_LOG_DIR}/access.log combined\n\n\t\tSSLEngine on\n\n\t\tSSLCertificateFile /etc/apache2/ssl/apache.crt\n\t\tSSLCertificateKeyFile /etc/apache2/ssl/apache.key\n\n\t\t<FilesMatch \"\.(cgi|shtml|phtml|php)$\">\n\t\t\tSSLOptions +StdEnvVars\n\t\t</FilesMatch>\n\n\t\t<Directory /usr/lib/cgi-bin>\n\t\t\tSSLOptions +StdEnvVars\n\t\t</Directory>\n\n\t</VirtualHost>\n\n"
end
vhostsssl = vhostsssl + "</IfModule>\n"

# Openssl args
opensslargs = ""
$vconfig['ssl'].each do |k, v|
	opensslargs = opensslargs+v+'\n'
end

####################################
### Running Vagrant
####################################
Vagrant.configure("2") do |config|
	config.vagrant.host = :detect
	config.ssh.shell = $vconfig['vagrant']['ssh_shell']
	config.ssh.username = $vconfig['vagrant']['ssh_username']
	config.ssh.keep_alive = true

	####################################
	### Machine Setup
	####################################
	config.vm.box = $vconfig['vagrant']['box']
	config.vm.box_url = $vconfig['vagrant']['box_url']
	config.vm.network "private_network", ip: $vconfig['vagrant']['box_ip']
	config.vm.hostname = $vconfig['vagrant']['vm_hostname']
	config.vm.network "forwarded_port", guest: 80, host: $vconfig['vagrant']['box_port']
	config.vm.network "forwarded_port", guest: 3306, host: $vconfig['mysql']['port']
	config.vm.network "forwarded_port", guest: 443, host: $vconfig['vagrant']['box_port_ssl']
	config.vm.synced_folder $vconfig['vagrant']['vm_webroot'], $vconfig['vagrant']['vm_docroot'], :owner => "vagrant", :group => "www-data", :mount_options => ["dmode=777","fmode=777"]
  
	####################################
	### VirtualBox Provider
	####################################
	config.vm.provider "virtualbox" do |virtualbox|
		virtualbox.customize ["modifyvm", :id, "--cpuexecutioncap", $vconfig['vagrant']['vm_cpu']]
		virtualbox.customize ["modifyvm", :id, "--name", $vconfig['vagrant']['vm_name']]
		virtualbox.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
		virtualbox.customize ["modifyvm", :id, "--memory", $vconfig['vagrant']['vm_memory']]
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
			"ssh_username" => $vconfig['vagrant']['ssh_username'],
			"fqdn" => $vconfig['vagrant']['vm_hostname'],
			"syspackages" => $vconfig['syspackages'].join(','),
			"phpmodules" => $vconfig['phpmodules'].join(','),
			"apachemodules" => $vconfig['apachemodules'].join(','),
			"vhostsphp" => $vconfig['vhosts'].join(','),
			"vhosts" => vhosts,
			"vhostsssl" => vhostsssl,
			"opensslargs" => opensslargs,
			"email" => email,
			"xdebug" => $vconfig['xdebug'].join("\n")+"\n",
			"errors" => $vconfig['errors'].join("\n")+"\n",
			"password" => $vconfig['mysql']['password'],
		}
		puppet.options = "--verbose"
		puppet.manifests_path = "config/puppet/manifests"
		puppet.manifest_file = "default.pp"
		puppet.module_path = "config/puppet/modules"
	end

	####################################
	### Run SQL
	####################################
	config.vm.provision "shell",
    inline: "mysql -uroot -p"+$vconfig['mysql']['password']+" < '/etc/mysql/remote.sql'"
	
	####################################
	### Ready
	####################################
	config.vm.provision "shell",
    inline: "cat /vagrant/config/shell/ready.txt"
end