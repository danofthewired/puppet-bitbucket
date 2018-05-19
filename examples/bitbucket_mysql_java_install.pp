node default {

  $version = '5.10.0'

  include ::java
  include ::git

  class { '::mysql::server':
    root_password => 'strongpassword',
  } ->

  mysql::db { 'bitbucket':
    user     => 'bitbucket',
    password => 'password',
    host     => 'localhost',
    grant    => ['ALL'],
  } ->

  class { '::bitbucket':
    version  => $version,
    javahome => '/opt/java',
    dbdriver => 'com.mysql.jdbc.Driver',
  } ->

  class { '::mysql_java_connector':
    links  => [ "/opt/bitbucket/atlassian-bitbucket-${version}/lib" ],
    notify => Service['bitbucket'],
  }

  class { '::bitbucket::facts': }

  
}
