# == Class: bitbucket::service
#
# This manages the bitbucket service. See README.md for details
# 
class bitbucket::service  (

  $service_manage        = $bitbucket::service_manage,
  $service_ensure        = $bitbucket::service_ensure,
  $service_enable        = $bitbucket::service_enable,
  $service_file_location = $bitbucket::params::service_file_location,
  $service_file_template = $bitbucket::params::service_file_template,
  $service_lockfile      = $bitbucket::params::service_lockfile,

) {

  validate_bool($service_manage)

  file { $service_file_location:
    content => template($service_file_template),
    mode    => '0755',
  }

  if $bitbucket::service_manage {

    validate_string($service_ensure)
    validate_bool($service_enable)

    if $::osfamily == 'RedHat' and $::operatingsystemmajrelease == '7' {
      exec { 'refresh_systemd':
        command     => 'systemctl daemon-reload',
        refreshonly => true,
        subscribe   => File[$service_file_location],
        before      => Service['bitbucket'],
      }
    }

    service { 'bitbucket':
      ensure  => $service_ensure,
      enable  => $service_enable,
      require => File[$service_file_location],
    }
  }

}
