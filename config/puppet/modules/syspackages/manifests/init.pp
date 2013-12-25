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
}