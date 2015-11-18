# == Class: bitbucket::params
#
# Defines default values for bitbucket module
#
class bitbucket::params {
  case $::osfamily {
    /RedHat/: {
      if $::operatingsystemmajrelease == '7' {
        $json_packages           = 'rubygem-json'
        $service_file_location   = '/usr/lib/systemd/system/bitbucket.service'
        $service_file_template   = 'bitbucket/bitbucket.service.erb'
        $service_lockfile        = '/var/lock/subsys/bitbucket'
      } elsif $::operatingsystemmajrelease == '6' {
        $json_packages           = [ 'rubygem-json', 'ruby-json' ]
        $service_file_location   = '/etc/init.d/bitbucket'
        $service_file_template   = 'bitbucket/bitbucket.initscript.redhat.erb'
        $service_lockfile        = '/var/lock/subsys/bitbucket'
      } else {
        fail("${::operatingsystem} ${::operatingsystemmajrelease} not supported")
      }
    } /Debian/: {
      $json_packages           = [ 'rubygem-json', 'ruby-json' ]
      $service_file_location   = '/etc/init.d/bitbucket'
      $service_file_template   = 'bitbucket/bitbucket.initscript.debian.erb'
      $service_lockfile        = '/var/lock/bitbucket'
    } default: {
      fail("${::operatingsystem} ${::operatingsystemmajrelease} not supported")
    }
  }
}
