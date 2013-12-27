class phpmyadmin
{
	package 
	{ 
		"phpmyadmin":
		ensure => latest,
		require => Package['mysql-server']
	}

	file
	{
		"/etc/apache2/conf-enabled/phpmyadmin.conf":
		ensure => link,
		target => "/etc/phpmyadmin/apache.conf",
		require => Package['phpmyadmin'],
		notify => Service['apache2']
	}
}