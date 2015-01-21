class composer ($startmsg)
{
	####################################
	### Composer
	####################################

	notify
	{
		'msg_composer':
		message => "${startmsg}",
		loglevel => info
	}

	# Download and add to path
	exec
	{ 
		"composer":
		command => "curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer",
		require => Notify['msg_composer']
	}
}