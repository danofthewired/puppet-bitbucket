node default {

  include ::git

  class { '::postgresql::globals':
    manage_package_repo => true,
    version             => '9.3',
  }->
  class { '::postgresql::server': } ->
  deploy::file { 'jdk-7u71-linux-x64.tar.gz':
    target          => '/opt/java',
    fetch_options   => '-q -c --header "Cookie: oraclelicense=accept-securebackup-cookie"',
    url             => 'http://download.oracle.com/otn-pub/java/jdk/7u71-b14/',
    download_timout => 1800,
    strip           => true,
  } ->
  class { '::bitbucket':
    version  => '4.0.2',
    javahome => '/opt/java',
    proxy    => {
      scheme    => 'http',
      proxyName => $::ipaddress_eth1,
      proxyPort => '80',
    },
  }
  class { '::bitbucket::gc': }
  class { '::bitbucket::facts': }
  postgresql::server::db { 'bitbucket':
    user     => 'bitbucket',
    password => postgresql_password('bitbucket', 'password'),
  }
}
