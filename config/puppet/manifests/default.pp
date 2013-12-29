####################################
### Default Paths
####################################
Exec
{
  path => ["/usr/bin", "/bin", "/usr/sbin", "/sbin", "/usr/local/bin", "/usr/local/sbin"]
}

####################################
### System Setup
####################################
$syspackages_arr = split($syspackages,',')

# Update list of packages
exec
{
	"apt-get update":
	command => "apt-get update",
}

# Install system packages
package
{
	$syspackages_arr:
	ensure => latest,
	require => Exec["apt-get update"],
}

# Add repo with latest Apache 2.4
exec
{
	"ppa:ondrej/apache2":
	command => "add-apt-repository ppa:ondrej/apache2 && apt-get update",
	require => Package["python-software-properties"],
}

# Add repo with latest PHP 5.5, then update apt-get again
exec
{
	"ppa:ondrej/php5":
	command => "add-apt-repository ppa:ondrej/php5 && apt-get update",
	require => Exec["ppa:ondrej/apache2"],
}

####################################
### Apache
####################################
$apachemodules_arr = split($apachemodules,',')

# Install Apache
package
{ 
	"apache":
	name => "apache2",
	ensure => latest,
	require => Exec['ppa:ondrej/php5'],
}

# Run Apache as a service, have it restart if those two files change
service
{ 
	"apache2":
    enable => true,
	ensure => running,
	require => Package["apache"],
	subscribe => [
  		File["/etc/apache2/mods-enabled/rewrite.load"],
  		File["/etc/apache2/sites-available/000-default.conf"]
	],
}

# Ensure rewrite link
file
{ 
	"/etc/apache2/mods-enabled/rewrite.load":
	ensure => link,
	target => "/etc/apache2/mods-available/rewrite.load",
	require => Package['apache'],
}

# Update the vhosts file
file
{
	"/etc/apache2/sites-available/000-default.conf":
	ensure => present,
	require => Package['apache'],
	content => $vhosts
}

# Load Apache modules
define apache::loadmodule () {
	exec {
		"/usr/sbin/a2enmod $name":
		unless => "/bin/readlink -e /etc/apache2/mods-enabled/${name}.load",
		require => Package["apache"]
	}
}

apache::loadmodule{$apachemodules_arr: }

####################################
### PHP
####################################
$phpmodules_arr = split($phpmodules,',')

# Install PHP
package
{
	"php":
	name => "php5",
	ensure => latest,
	require => Package["apache"],
}

# Install PHP Modules
package
{
	$phpmodules_arr:
	ensure => latest,
	require => Package["php"],
}

# Manually install PECL xdebug
exec
{
	"xdebug":
	command => "pecl install xdebug",
	require => Package[$syspackages_arr],
	notify => Service["apache2"],
	returns => [ 0, 1, '', ' ']
}

# Add some custom ini settings to override php.ini
file
{
	'/etc/php5/mods-available/custom.ini':
	ensure => present,
	require => Package["php"],
	content => $xdebug
}

####################################
### MySQL
####################################

$sqlaccess = "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '$password';\nFLUSH PRIVILEGES;"

# Install MySQL server
package 
{ 
	"mysql-server":
	ensure => latest,
	require => Package['php']
}

# Install MySQL client
package 
{ 
	"mysql-client":
	ensure => latest,
	require => Package['mysql-server']
}

# Run MySQL as a service
service
{ 
	"mysql":
    enable => true,
	ensure => running,
	require => Package['mysql-server'],
	subscribe => [
  		File["/etc/mysql/my.cnf"],
  		File["/etc/mysql/remote.sql"]
	],
}

# If it's the first run, set the password from config
exec
{ 
	"root-setup":
	command => "mysqladmin -uroot password $password",
	unless => "mysqladmin -uroot -p$password status",
	require => Service['mysql']
}

# Make sure bind-address is commented out
exec
{ 
	"bind-address":
	command => 'sed -i "s/^bind-address/#bind-address/" /etc/mysql/my.cnf',
	require => [Package['mysql-server'], File["/etc/mysql/my.cnf"]]
}

# Declare file resource so the service can subscribe to changes
file
{
	'/etc/mysql/my.cnf':
	ensure => present,
	require => Package["mysql-server"]
}

# Create an SQL file that we need.
file
{
	'/etc/mysql/remote.sql':
	ensure => present,
	require => Package["mysql-server"],
	content => $sqlaccess
}

####################################
### phpMyAdmin
####################################

# Install phpMyAdmin
package
{ 
	"phpmyadmin":
	ensure => latest,
	require => Package['mysql-server']
}

# Create vhost
file
{
	"/etc/apache2/conf-enabled/phpmyadmin.conf":
	ensure => link,
	target => "/etc/phpmyadmin/apache.conf",
	require => Package['phpmyadmin'],
	notify => Service['apache2']
}