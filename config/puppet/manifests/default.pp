####################################
### Default Paths
####################################
Exec
{
  path => ["/usr/bin", "/bin", "/usr/sbin", "/sbin", "/usr/local/bin", "/usr/local/sbin"]
}

####################################
### Build Arrays
####################################
$syspackages_arr = split($syspackages,',')
$apachemodules_arr = split($apachemodules,',')
$phpmodules_arr = split($phpmodules,',')



####################################
### Class Declarations
####################################

class
{
	'syspackages':
	syspackages_arr => $syspackages_arr,
	startmsg => "\n\n################## System Setup ##################\n\n"
}

class
{
	'apache':
	apachemodules_arr => $apachemodules_arr,
	vhosts => $vhosts,
	vhostsssl => $vhostsssl,
	startmsg => "\n\n################## Apache Setup ##################\n\n",
	opensslargs => $opensslargs,
	require => Class['syspackages']
}

class
{
	'php':
	phpmodules_arr => $phpmodules_arr,
	xdebug => $xdebug,
	errors => $errors,
	vhostsphp => $vhostsphp,
	startmsg => "\n\n################## PHP Setup ##################\n\n",
	require => Class['apache']
}

class
{
	'mysql':
	password => $password,
	startmsg => "\n\n################## MySQL Setup ##################\n\n",
	require => Class['php']
}

class
{
	'phpmyadmin':
	startmsg => "\n\n################## phpMyAdmin Setup ##################\n\n",
	require => Class['mysql']
}

class
{
	'composer':
	startmsg => "\n\n################## Composer Setup ##################\n\n",
	require => Class['phpmyadmin']
}