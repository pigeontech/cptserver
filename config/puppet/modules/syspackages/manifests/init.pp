class syspackages ($syspackages_arr, $startmsg)
{
	####################################
	### System Setup
	####################################

	# Output start of this section
	notify
	{
		'msg_syspackages':
		message => "${startmsg}",
		loglevel => info
	}

	exec
	{
		'apt-get update':
		command => 'apt-get update',
		require => Notify['msg_syspackages']
	}

	# This is needed for other repos
	package
	{
		'python-software-properties':
		ensure => latest,
		require => Exec['apt-get update'],
	}

	# This is needed for other repos
	package
	{
		'ppa-purge':
		ensure => latest,
		require => Package['python-software-properties'],
	}

	# Apache 2.4 repo
	exec 
	{
		'ondrej-apache':
		command => 'add-apt-repository -y ppa:ondrej/apache2',
		require => Package['ppa-purge']
	}

	# PHP 5.6 repo
	exec 
	{
		'ondrej-php':
		command => 'add-apt-repository -y ppa:ondrej/php5-5.6',
		require => Exec['ondrej-apache']
	}

	# Update list of packages again with new repos installed
	exec
	{
		'apt-get update2':
		command => 'apt-get update',
		require => Exec['ondrej-php']
	}

	# Install system packages
	define syspackages::loadmodule ($modname = $title) {
		package
		{
			$modname:
			ensure => latest,
			require => Exec['apt-get update2'],
		}
	}

	syspackages::loadmodule{$syspackages_arr: }
}