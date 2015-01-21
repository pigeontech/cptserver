class services ()
{
	####################################
	### Services
	####################################

	service
	{ 
		"apache":
		name => apache2,
	  enable => true,
		ensure => running,
		require => Package["apache"],
	}
}