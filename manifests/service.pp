# == Class: bitbucket::service
#
# This manages the bitbucket service. See README.md for details
#
class bitbucket::service  (

  $service_manage        = $bitbucket::service_manage,
  $service_ensure        = $bitbucket::service_ensure,
  $service_enable        = $bitbucket::service_enable,
  $service_file_location = $bitbucket::params::service_file_location,
  $service_file_mode     = $bitbucket::params::service_file_mode,
  $service_file_template = $bitbucket::params::service_file_template,
  $service_lockfile      = $bitbucket::params::service_lockfile,

) {

  assert_type(Boolean, $service_manage)

  if $bitbucket::service_manage {

    file { $service_file_location:
      content => template($service_file_template),
      mode    => $service_file_mode,
    }

    assert_type(String, $service_ensure)
    assert_type(Boolean, $service_enable)

    if ($::osfamily == 'RedHat' and $::operatingsystemmajrelease == '7') or ($::osfamily == 'Debian' and $::operatingsystemmajrelease == '16.04') {
      exec { 'bitbucket_refresh_systemd':
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
