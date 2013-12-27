class mysql
{
	package 
	{ 
		"mysql-server":
		ensure => latest,
		require => Package['php']
	}

	package 
	{ 
		"mysql-client":
		ensure => latest,
		require => Package['mysql-server']
	}

	service
	{ 
		"mysql":
	    enable => true,
		ensure => running,
		require => Package['mysql-server']
	}

	exec
	{ 
		"root-setup":
		command => "mysqladmin -uroot password $password",
		unless => "mysqladmin -uroot -p$password status",
	}
}