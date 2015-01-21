class phpmyadmin ($startmsg)
{
	####################################
	### phpMyAdmin
	####################################
	
	include ::services

	notify
	{
		'msg_phpmyadmin':
		message => "${startmsg}",
		loglevel => info
	}

	# Install phpMyAdmin
	package
	{ 
		"phpmyadmin":
		ensure => latest,
		require => Notify['msg_phpmyadmin']
	}

	# Create vhost
	file
	{
		"/etc/apache2/conf-enabled/phpmyadmin.conf":
		ensure => link,
		target => "/etc/phpmyadmin/apache.conf",
		require => Package['phpmyadmin'],
		notify => Service['apache']
	}
}