# == Class: bitbucket::params
#
# Defines default values for bitbucket module
#
class bitbucket::params {
  case $::osfamily {
    /RedHat/: {
      $systemd_unit_dir = '/usr/lib/systemd/system'
      $init_template    = 'bitbucket.initscript.redhat.erb'
      $service_lockfile = '/var/lock/subsys/bitbucket'

      if $::operatingsystemmajrelease == '7' or $::operatingsystemmajrelease == '8' {
        $json_packages = [ 'rubygem-json' ]
      } elsif $::operatingsystemmajrelease == '6' {
        $json_packages         = [ 'ruby-json', 'rubygem-json' ]
      } elsif $::operatingsystemmajrelease == '2018' {
        $json_packages         = [ 'ruby-json', 'rubygem-json' ]
      } else {
        fail("${::operatingsystem} ${::operatingsystemmajrelease} not supported")
      }
    } /Debian/: {
      $systemd_unit_dir = '/etc/systemd/system'
      $init_template    = 'bitbucket.initscript.debian.erb'
      $service_lockfile = '/var/lock/bitbucket'
      $json_packages    = [ 'rubygem-json', 'ruby-json' ]
    } default: {
      fail("${::operatingsystem} ${::operatingsystemmajrelease} not supported")
    }
  }

  case $service_provider {
    'systemd': {
      $service_file_location = "${systemd_unit_dir}/bitbucket.service"
      $service_file_template = 'bitbucket/bitbucket.service.erb'
      $service_file_mode     = '0644'
    }
    default: {
      $service_file_location = '/etc/init.d/bitbucket'
      $service_file_template = "bitbucket/${init_template}"
      $service_file_mode     = '0754'
    }
  }

}
