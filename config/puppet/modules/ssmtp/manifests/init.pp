class ssmtp ($email, $startmsg)
{
	####################################
	### ssmtp
	####################################

	notify
	{
		'msg_email':
		message => "${startmsg}",
		loglevel => info
	}

	# Update ssmtp file
	file
	{
		"/etc/ssmtp/ssmtp.conf":
		ensure => present,
		require => Notify['msg_email'],
		content => "${email}"
	}

}