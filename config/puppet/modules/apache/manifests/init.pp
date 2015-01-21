class apache ($apachemodules_arr, $vhosts, $vhostsssl, $startmsg, $opensslargs)
{
	####################################
	### Apache
	####################################

	notify
	{
		'msg_apache':
		message => "${startmsg}",
		loglevel => info
	}

	# Install Apache
	package
	{ 
		"apache":
		name => "apache2",
		ensure => latest,
		require => Notify['msg_apache']
	}

	# Run Apache as a service, have it restart if those files change
	include ::services

	# Ensure rewrite link
	file
	{ 
		"/etc/apache2/mods-enabled/rewrite.load":
		ensure => link,
		target => "/etc/apache2/mods-available/rewrite.load",
		require => Package['apache'],
		notify => Service['apache']
	}

	# Update the vhosts file
	file
	{
		"/etc/apache2/sites-available/000-default.conf":
		ensure => present,
		require => Package['apache'],
		content => "${vhosts}",
		notify => Service['apache']
	}

	# Update ssl vhosts file
	file
	{
		"/etc/apache2/sites-available/default-ssl.conf":
		ensure => present,
		require => Package['apache'],
		content => "${vhostsssl}",
		notify => Service['apache']
	}

	# Load Apache modules
	define apache::loadmodule ($modname = $title) {
		exec {
			"/usr/sbin/a2enmod ${modname}":
			unless => "/bin/readlink -e /etc/apache2/mods-enabled/${modname}.load",
			require => Package['apache'],
			notify => Service['apache']
		}
	}

	apache::loadmodule{$apachemodules_arr: }

	# enable default-ssl.conf
	exec {
		"default-ssl":
		command => "a2ensite default-ssl",
		unless => "/bin/readlink -e /etc/apache2/sites-enabled/default-ssl.conf",
		require => Package['apache'],
		notify => Service['apache']
	}

	file 
	{ 
		"/var/www/html":
		ensure => absent,
		require => Exec['default-ssl'],
		force => true
	}

	file {
		"/etc/apache2/ssl":
		ensure => directory,
		require => Package['apache']
	}

	# Get rid of the "It works!" file Apache installs
	file {
		"/var/www/index.html":
		ensure => absent,
		require => Package['apache']
	}

	# create ssl certificate and key
	exec {
		"cert-key":
		command => "echo \"${opensslargs}\" | openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/apache2/ssl/apache.key -out /etc/apache2/ssl/apache.crt",
		require => [Package['apache'], File['/etc/apache2/ssl']],
		returns => [0,1],
		notify => Service['apache']
	}
}