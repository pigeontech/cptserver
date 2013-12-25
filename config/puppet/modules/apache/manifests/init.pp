class apache
{
	$apachemodules = split($apachemodules,',')

	package
	{ 
		"apache":
		name => "apache2",
		ensure => latest,
		require => [Package[split($syspackages,',')], Exec["apt-get update"]]
	}

	service
	{ 
		"apache2":
	    enable => true,
		ensure => running,
		require => Package["apache"],
		subscribe => [
      		File["/etc/apache2/mods-enabled/rewrite.load"],
      		File["/etc/apache2/sites-available/default"]
    	],
	}

	file
	{ 
		"/etc/apache2/mods-enabled/rewrite.load":
		ensure => link,
		target => "/etc/apache2/mods-available/rewrite.load",
		require => Package['apache'],
	}

	file
	{
		"/etc/apache2/sites-available/default":
		ensure => present,
		require => Package['apache'],
	}

	define apache::loadmodule () {
		exec {
			"/usr/sbin/a2enmod $name":
			unless => "/bin/readlink -e /etc/apache2/mods-enabled/${name}.load",
			require => Package["apache"]
		}
	}

	apache::loadmodule{$apachemodules: }


}