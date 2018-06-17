# == Class: bitbucket::facts
#
# Class to add some facts for bitbucket. They have been added as an external fact
# because we do not want to distrubute these facts to all systems.
#
# === Parameters
#
# [*port*]
#   port that bitbucket listens on.
# [*uri*]
#   ip that bitbucket is listening on, defaults to localhost.
#
# === Examples
#
# class { 'bitbucket::facts': }
#
class bitbucket::facts(
  $ensure        = 'present',
  $port          = '7990',
  $uri           = '127.0.0.1',
  $context_path  = $bitbucket::context_path,
  $json_packages = $bitbucket::params::json_packages,
  $is_https      = false,
) inherits bitbucket {

  if $::osfamily == 'RedHat' and $::puppetversion !~ /Puppet Enterprise/ {
    ensure_packages ($json_packages, { ensure => present })
  }

  if $is_https {
    $http = 'https://'
  }else{
    $http = 'http://'
  }

  file{'/etc/bitbucket_url.txt':
    ensure  => $ensure,
    content => "${http}${uri}:${port}${context_path}/rest/api/1.0/\
application-properties",
  }
}
