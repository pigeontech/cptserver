class syspackages
{
	$syspackages = split($syspackages,',')

	exec
	{
		"apt-get update":
		command => "apt-get update",
	}

	package
	{
		$syspackages:
		ensure => latest,
		require => Exec["apt-get update"],
	}

	exec
	{
		"ppa:ondrej/apache2":
		command => "add-apt-repository ppa:ondrej/apache2 && apt-get update",
		require => Package["python-software-properties"],
	}

	exec
	{
		"ppa:ondrej/php5":
		command => "add-apt-repository ppa:ondrej/php5 && apt-get update",
		require => Exec["ppa:ondrej/apache2"],
	}
}