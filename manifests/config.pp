# == Class: bitbucket
#
# This configures the bitbucket module. See README.md for details
#
class bitbucket::config(
  $version      = $bitbucket::version,
  $user         = $bitbucket::user,
  $group        = $bitbucket::group,
  $proxy        = $bitbucket::proxy,
  $context_path = $bitbucket::context_path,
  $tomcat_port  = $bitbucket::tomcat_port,
  $config_properties = $bitbucket::config_properties,
) {

  # Atlassian changed where files are installed from ver 3.2.0
  # See issue #16 for more detail
  if versioncmp($version, '3.2.0') > 0 {
    $moved = 'shared/'
    file { "${bitbucket::homedir}/${moved}":
      ensure  => 'directory',
      owner   => $user,
      group   => $group,
      require => File[$bitbucket::homedir],
    }
  } else {
    $moved = undef
  }

  File {
    owner => $bitbucket::user,
    group => $bitbucket::group,
  }

  if versioncmp($version, '3.8.0') >= 0 {
    $server_xml = "${bitbucket::homedir}/shared/server.xml"
  } else {
    $server_xml = "${bitbucket::webappdir}/conf/server.xml"
  }

  file { "${bitbucket::webappdir}/bin/setenv.sh":
    content => template('bitbucket/setenv.sh.erb'),
    mode    => '0750',
    require => Class['bitbucket::install'],
    notify  => Class['bitbucket::service'],
  } ->

  file { "${bitbucket::webappdir}/bin/user.sh":
    content => template('bitbucket/user.sh.erb'),
    mode    => '0750',
    require => [
      Class['bitbucket::install'],
      File[$bitbucket::webappdir],
      File[$bitbucket::homedir]
    ],
  }->

  file { $server_xml:
    content => template('bitbucket/server.xml.erb'),
    mode    => '0640',
    require => Class['bitbucket::install'],
    notify  => Class['bitbucket::service'],
  } ->

  ini_setting { 'bitbucket_httpport':
    ensure  => present,
    path    => "${bitbucket::webappdir}/conf/scripts.cfg",
    section => '',
    setting => 'bitbucket_httpport',
    value   => $tomcat_port,
    require => Class['bitbucket::install'],
    before  => Class['bitbucket::service'],
  } ->

  file { "${bitbucket::homedir}/${moved}bitbucket.properties":
    content => template('bitbucket/bitbucket.properties.erb'),
    mode    => '0640',
    require => [
      Class['bitbucket::install'],
      File[$bitbucket::webappdir],
      File[$bitbucket::homedir]
    ],
  }
}
