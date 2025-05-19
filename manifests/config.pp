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
    $shared_dir = "${bitbucket::homedir}/${moved}"
    # Shared directory may be already defined when installing DataCenter instances (NFS mounted)
    if ! defined(File[$shared_dir]) {
      file { $shared_dir:
        ensure  => 'directory',
        owner   => $user,
        group   => $group,
        require => File[$bitbucket::homedir],
      }
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

  if versioncmp($version, '5.0.0') >= 0 {
    $bitbucket_http_port_ensure = 'absent'
    $bitbucket_server_xml_ensure = 'absent'
    $bitbucket_user_script = 'set-bitbucket-user'
    $bitbucket_startup_script = '_start-webapp'
  } else {
    $bitbucket_http_port_ensure = 'present'
    $bitbucket_server_xml_ensure = 'present'
    $bitbucket_user_script = 'user'
    $bitbucket_startup_script = 'setenv'
  }

  file { "${bitbucket::webappdir}/bin/${bitbucket_startup_script}.sh":
    content => template("bitbucket/${bitbucket_startup_script}.sh.erb"),
    mode    => '0750',
    require => Class['bitbucket::install'],
    notify  => Class['bitbucket::service'],
  } ->

  file { "${bitbucket::webappdir}/bin/${bitbucket_user_script}.sh":
    content => template("bitbucket/${bitbucket_user_script}.sh.erb"),
    mode    => '0750',
    require => [
      Class['bitbucket::install'],
      File[$bitbucket::webappdir],
      File[$bitbucket::homedir]
    ],
  }->

  file { $server_xml:
    ensure  => $bitbucket_server_xml_ensure,
    content => template('bitbucket/server.xml.erb'),
    mode    => '0640',
    require => Class['bitbucket::install'],
    notify  => Class['bitbucket::service'],
  } ->

  ini_setting { 'bitbucket_httpport':
    ensure  => $bitbucket_http_port_ensure,
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

  if versioncmp($version, '7.21') >= 0 {
    $search_config = "${bitbucket::webappdir}/opensearch/config/opensearch.yml"
    $search_config_template = 'bitbucket/opensearch.yml.erb'
  } else {
    $search_config = "${bitbucket::webappdir}/elasticsearch/config-template/elasticsearch.yml"
    $search_config_template = 'bitbucket/elasticsearch.yml.erb'
  }
  file { $search_config:
    content => template($search_config_template),
    mode    => '0640',
    require => [
      Class['bitbucket::install'],
      File[$bitbucket::webappdir],
    ],
  }

  file { "${bitbucket::webappdir}/app/WEB-INF/classes/logback.xml":
    content => template('bitbucket/logback.xml.erb'),
    mode    => '0640',
    require => [
      Class['bitbucket::install'],
      File[$bitbucket::webappdir]
    ],
  }
}
