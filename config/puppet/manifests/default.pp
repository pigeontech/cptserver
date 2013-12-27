####################################
### Default Paths
####################################
Exec
{
  path => ["/usr/bin", "/bin", "/usr/sbin", "/sbin", "/usr/local/bin", "/usr/local/sbin"]
}


####################################
### Includes
####################################
include syspackages
include apache
include php