class php
{
	$phpmodules = split($phpmodules,',')

	package
	{
		"php":
		name => "php5",
		ensure => latest,
		require => Package["apache"],
	}

	package
	{
		$phpmodules:
		ensure => latest,
		require => Package["php"],
	}

	exec
	{
		"xdebug":
		command => "pecl install xdebug",
		require => Package[split($syspackages,',')],
		notify => Service["apache2"],
		returns => [ 0, 1, '', ' ']
	}

	file {'/etc/php5/conf.d/custom.ini':
		ensure => present,
		owner => root, group => root, mode => 644,
		require => Package["php"],
		content => $xdebug
	}
}