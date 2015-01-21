class mysql ($password, $startmsg)
{
	####################################
	### MySQL
	####################################

	$sqlaccess = "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '$password';\nFLUSH PRIVILEGES;"

	notify
	{
		'msg_mysql':
		message => "${startmsg}",
		loglevel => info
	}

	# Install MySQL server
	package 
	{ 
		"mysql":
		name => "mysql-server",
		ensure => latest,
		require => Notify['msg_mysql']
	}

	# Install MySQL client
	package 
	{
		"mysql-client":
		ensure => latest,
		require => Package['mysql']
	}

	# Declare file resource so the service can subscribe to changes
	file
	{
		'/etc/mysql/my.cnf':
		ensure => present,
		require => Package["mysql"]
	}
	
	# Create an SQL file that we need.
	file
	{
		'/etc/mysql/remote.sql':
		ensure => present,
		require => Package["mysql"],
		content => $sqlaccess
	}

	# Run MySQL as a service
	service
	{ 
		"mysql":
	    enable => true,
		ensure => running,
		require => [File["/etc/mysql/my.cnf"], File["/etc/mysql/remote.sql"]],
		subscribe => [
	  		File["/etc/mysql/my.cnf"],
	  		File["/etc/mysql/remote.sql"]
		],
	}

	# If it's the first run, set the password from config
	exec
	{
		"root-setup":
		command => "mysqladmin -uroot password ${password}",
		unless => "mysqladmin -uroot -p${password} status",
		require => Service['mysql']
	}

	# Make sure bind-address is commented out
	exec
	{ 
		"bind-address":
		command => 'sed -i "s/^bind-address/#bind-address/" /etc/mysql/my.cnf',
		require => File["/etc/mysql/my.cnf"]
	}
}