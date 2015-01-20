class php ($phpmodules_arr, $xdebug, $errors, $vhostsphp, $startmsg)
{
	####################################
	### PHP
	####################################

	include ::services

	notify
	{
		'msg_php':
		message => $startmsg,
		loglevel => info
	}

	# Install PHP
	package
	{
		'php':
		name => "php5",
		ensure => latest,
		require => Notify['msg_php']
	}

	# Install PHP Modules
	define php::loadmodule ($modname = $title) {
		package
		{
			$modname:
			ensure => latest,
			require => Package["php"],
		}
	}

	php::loadmodule{$phpmodules_arr: }

	# Add some custom xdebug ini settings to override any in php.ini
	file
	{
		'/etc/php5/mods-available/xdebug.ini':
		ensure => present,
		require => Package["php"],
		content => $xdebug,
		notify => Service['apache']
	}

	# Email
	file
	{
		'/etc/php5/mods-available/sendmail.ini':
		ensure => present,
		require => Package["php"],
		content => "sendmail_path = /usr/sbin/sendmail -t",
		notify => Service['apache']
	}

	# Error settings
	file
	{
		'/etc/php5/mods-available/errors.ini':
		ensure => present,
		require => Package["php"],
		content => $errors,
		notify => Service['apache']
	}

	# Error link
	file
	{ 
		"/etc/php5/apache2/conf.d/errors.ini":
		ensure => link,
		target => "/etc/php5/mods-available/errors.ini",
		require => Package['php'],
		notify => Service['apache']
	}

	# Add a vhost file to our default website
	file
	{
		'/var/www/default/vhosts.txt':
		ensure => present,
		require => Package["php"],
		content => $vhostsphp
	}
}