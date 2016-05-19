#puppet-bitbucket
[![Build Status](https://travis-ci.org/danofthewired/puppet-bitbucket.svg?branch=master)](https://travis-ci.org/danofthewired/puppet-bitbucket)
[![Puppet Forge](http://img.shields.io/puppetforge/v/thewired/bitbucket.svg)](https://forge.puppetlabs.com/thewired/bitbucket)

####Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with Bitbucket](#setup)
    * [Bitbucket Prerequisites](#Bitbucket-prerequisites)
    * [What Bitbucket affects](#what-Bitbucket-affects)
    * [Beginning with Bitbucket](#beginning-with-Bitbucket)
    * [Upgrades](#upgrades)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
6. [Limitations - OS compatibility, etc.](#limitations)
7. [Development - Guide for contributing to the module](#development)
8. [Testing - How to test the Bitbucket module](#testing)
9. [Contributors](#contributors)

##Overview

This is a puppet module to install Atlassian Bitbucket. On-premises source code management for Git that's secure, fast, and enterprise grade.

|Module Version   | Supported Stash/Bitbucket versions  |
|-----------------|-------------------------------------|
| 2.0.x           | 4.x.x                               |

##Module Description

This module installs/upgrades Atlassian's Enterprise source code management tool. The Bitbucket module also manages the bitbucket configuration files with Puppet.

##Setup
<a name="Bitbucket-prerequisites">
###Bitbucket Prerequisites
* Bitbucket requires a Java Developers Kit (JDK) or Java Run-time Environment (JRE) platform to be installed on your server's operating system. Oracle JDK / JRE (formerly Sun JDK / JRE)  versions 7 and 8 and Open JDK/ JRE versions 7 and 8 are currently supported by Atlassian.

* Bitbucket requires a relational database to store its configuration data. This module currently supports PostgreSQL 8.4 to 9.x and MySQL 5.x. We suggest using puppetlabs-postgresql/puppetlabs-mysql modules to configure/manage the database. The module uses PostgreSQL as a default.

* Whilst not required, for production use we recommend using nginx/apache as a reverse proxy to Bitbucket. We suggest using the jfryman/nginx puppet module.

###What Bitbucket affects
If installing to an existing Bitbucket instance, it is your responsibility to backup your database. We also recommend that you backup your Bitbucket home directory and that you align your current Bitbucket version with the version you intend to use with puppet Bitbucket module.

You must have your database setup with the account user that Bitbucket will use. This can be done using the puppetlabs-postgresql and puppetlabs-mysql modules. The mysql java connector can be installed using the [puppet/mysql_java_connector](https://forge.puppetlabs.com/puppet/mysql_java_connector) module.

When using this module to upgrade Bitbucket, please make sure you have a database/Bitbucket home backup. We plan to include a class for backing up the bitbucket home directory in a future release.

###Beginning with Bitbucket
This puppet module will automatically download the Bitbucket tar.gz from Atlassian and extracts it into /opt/bitbucket/atlassian-bitbucket-$version. The default Bitbucket home is /home/bitbucket.

#####Basic examples
```puppet
  class { 'bitbucket':
    javahome    => '/opt/java',
  }
```

```puppet
  class { 'bitbucket':
    version        => '4.2.0',
    javahome       => '/opt/java',
    dburl          => 'jdbc:postgresql://bitbucket.example.com:5433/bitbucket',
    dbpassword     => $bitbucketpass,
  }
```
Schedule a weekly git garbage collect for all repositories.
```puppet
  class { 'bitbucket::gc': }
```
Enable external facts for bitbucket version.
```puppet
  class { 'bitbucket::facts': }
```
Enable a bitbucket backup
```puppet
  class { 'bitbucket':
    backup_ensure          => present,
    backupclient_version    => '2.0.2',
    backup_home            => '/opt/bitbucket-backup',
    backupuser             => 'admin',
    backuppass             => 'password',
    backup_keep_age        => '3d',
    backup_schedule_hour   => '5',
    backup_schedule_minute => '0',
  }
```

<a name="upgrades">
#####Upgrades

######Upgrades to Bitbucket

Bitbucket can be upgraded by incrementing this version number. This will *STOP* the running instance of Bitbucket and attempt to upgrade. You should take caution when doing large version upgrades. Always backup your database and your home directory. The bitbucket::facts class is required for upgrades.

```puppet
  class { 'bitbucket':
    javahome => '/opt/java',
    version  => '4.2.0',
  }
  class { 'bitbucket::facts': }
```
If the bitbucket service is managed outside of puppet the stop_bitbucket paramater can be used to shut down bitbucket.
```puppet
  class { 'bitbucket':
    javahome   => '/opt/java',
    version    => '4.2.0',
    stop_bitbucket => 'crm resource stop bitbucket && sleep 15',
  }
  class { 'bitbucket::facts': }
```

##Usage

This module also allows for direct customization of the JVM, following [Atlassian's recommendations](https://confluence.atlassian.com/display/JIRA/Setting+Properties+and+Options+on+Startup)

This is especially useful for setting properties such as HTTP/https proxy settings. Support has also been added for reverse proxying bitbucket via Apache or nginx.

####A more complex example

```puppet
  class { 'bitbucket':
    version        => '4.2.0',
    installdir     => '/opt/atlassian/atlassian-bitbucket',
    homedir        => '/opt/atlassian/application-data/bitbucket-home',
    javahome       => '/opt/java',
    download_url    => 'http://example.co.za/pub/software/development-tools/atlassian/',
    dburl          => 'jdbc:postgresql://dbvip.example.co.za:5433/bitbucket',
    dbpassword     => $bitbucketpass,
    service_manage => false,
    jvm_xms        => '1G',
    jvm_xmx        => '4G',
    java_opts      => '-Dhttp.proxyHost=proxy.example.co.za -Dhttp.proxyPort=8080 -Dhttps.proxyHost=proxy.example.co.za -Dhttps.proxyPort=8080 -Dhttp.nonProxyHosts=\"localhost|127.0.0.1|172.*.*.*|10.*.*.*|*.example.co.za\"',
    proxy          => {
      scheme       => 'https',
      proxyName    => 'bitbucket.example.co.za',
      proxyPort    => '443',
    },
    tomcat_port    => '7991'
  }
  class { 'bitbucket::facts': }
  class { 'bitbucket::gc': }
```

### A Hiera example

This example is used in production for 500 users in an traditional enterprise environment. Your mileage may vary. The dbpassword can be stored using eyaml hiera extension.

```yaml
# Bitbucket configuration
bitbucket::version:        '4.2.0'
bitbucket::installdir:     '/opt/atlassian/atlassian-bitbucket'
bitbucket::homedir:        '/opt/atlassian/application-data/bitbucket-home'
bitbucket::javahome:       '/opt/java'
bitbucket::dburl:          'jdbc:postgresql://dbvip.example.co.za:5433/bitbucket'
bitbucket::service_manage: false
bitbucket::download_url:    'http://example.co.za/pub/software/development-tools/atlassian'
bitbucket::jvm_xms:        '1G'
bitbucket::jvm_xmx:        '4G'
bitbucket::java_opts: >
  -XX:+UseLargePages
  -Dhttp.proxyHost=proxy.example.co.za
  -Dhttp.proxyPort=8080
  -Dhttps.proxyHost=proxy.example.co.za
  -Dhttps.proxyPort=8080
  -Dhttp.nonProxyHosts=localhost\|127.0.0.1\|172.*.*.*\|10.*.*.*\|*.example.co.za
bitbucket::env:
  - 'http_proxy=proxy.example.co.za:8080'
  - 'https_proxy=proxy.example.co.za:8080'
bitbucket::proxy:
  scheme:     'https'
  proxyName:  'bitbucket.example.co.za'
  proxyPort:  '443'
bitbucket::bitbucket_stop: '/usr/sbin crm resource stop bitbucket'
```

##Reference

###Classes

####Public Classes

* `bitbucket`: Main class, manages the installation and configuration of Bitbucket.
* `bitbucket::facts`: Enable external facts for running instance of Bitbucket. This class is required to handle upgrades of Bitbucket. As it is an external fact, we chose not to enable it by default.
* `bitbucket::gc`: Schedule a weekly git garbage collect for all repositories
* `bitbucket::backup`: Schedule a backup of bitbucket

####Private Classes

* `bitbucket::install`: Installs Bitbucket binaries
* `bitbucket::config`: Modifies Bitbucket/tomcat configuration files
* `bitbucket::service`: Manage the Bitbucket service.

###Parameters

####Bitbucket parameters####
#####`javahome`
Specify the java home directory. No assumptions are made re the location of java and therefore this option is required. Default: undef
#####`version`
Specifies the version of Bitbucket to install, defaults to latest available at time of module upload to the forge. It is **recommended** to pin the version number to avoid unnecessary upgrades of Bitbucket
#####`format`
The format of the file bitbucket will be installed from. Default: 'tar.gz'
#####`installdir`
The installation directory of the bitbucket binaries. Default: '/opt/bitbucket'
#####`homedir`
The home directory of bitbucket. Configuration files are stored here. Default: '/home/bitbucket'
#####`manage_usr_grp`
Whether or not this module will manage the bitbucket user and group associated with the install. 
You must either allow the module to manage both aspects or handle both outside the module. Default: true
#####`user`
The user that bitbucket should run as, as well as the ownership of bitbucket related files. Default: 'atlbitbucket'
#####`group`
The group that bitbucket files should be owned by. Default: 'atlbitbucket'
#####`uid`
Specify a uid of the bitbucket user. Default: undef
#####`gid`
Specify a gid of the bitbucket user: Default: undef
#####`context_path`
Specify context path, defaults to ''.
If modified, Once Bitbucket has started, go to the administration area and click Server Settings (under 'Settings'). Append the new context path to your base URL.
#####`tomcat_port`
Specify the port that you wish to run tomcat under, defaults to 7990

####database parameters####

#####`dbuser`
The name of the database user that bitbucket should use. Default: 'bitbucket'
#####`dbpassword`
The database password for the database user. Default: 'password'
#####`dburl`
The uri to the bitbucket database server. Default: 'jdbc:postgresql://localhost:5432/bitbucket'
#####`dbdriver`
The driver to use to connect to the database. Default: 'org.postgresql.Driver'

####JVM Java parameters####

#####`jvm_xms`
Default: '256m'
#####`jvm_xmx`
Default: '1024m'
#####`jvm_optional`
Default: '-XX:-HeapDumpOnOutOfMemoryError'
#####`jvm_support_recommended_args`
Default: ''
#####`java_opts`
Default: ''

####Tomcat parameters####

#####`proxy`
Reverse https proxy configuration. See examples for more detail. Default: {}

####Miscellaneous  parameters####

#####`download_url`
Where to download the bitbucket binaries from. Default: 'https://downloads.atlassian.com/software/stash/downloads'
#####`checksum`
The md5 checksum of the archive file. Only supported with `deploy_module => archive`. Defaults to 'undef'
#####`service_manage`
Should puppet manage this service? Default: true
#####`$service_ensure`
Manage the bitbucket service, defaults to 'running'
#####`$service_enable`
Defaults to 'true'
#####`$stop_bitbucket`
If the bitbucket service is managed outside of puppet the stop_bitbucket paramater can be used to shut down bitbucket for upgrades. Defaults to 'service bitbucket stop && sleep 15'
#####`deploy_module`
Module to use for installed bitbucket archive fille. Supports puppet-archive and nanliu-staging. Defaults to 'archive'. Archive supports md5 hash checking, Staging supports s3 buckets. 
#####`config_properties`
Extra configuration options for bitbucket (bitbucket-config.properties). See https://confluence.atlassian.com/display/STASH/Bitbucket+config+properties for available options. Must be a hash, Default: {}
#####`umask`
Specify the umask bitbucket should run with. Defaults to undef, in which case the user account's default umask is left untouched.

####Backup parameters####
#####`manage_backup`
Whether to manage installation of backup client or not. Defaults to true.
#####`backup_ensure`
Enable or disable the backup cron job. Defaults to present.
#####`backupclient_version`
The version of the backup client to install. Defaults to '2.0.2'
#####`backup_home`
Home directory to use for backups. Backups are created here under /archive. Defaults to '/opt/bitbucket-backup'.
#####`backupuser`
The username to use to initiate the bitbucket backup. Defaults to 'admin'
#####`backuppass`
The password to use to initiate the bitbucket backup. Defaults to 'password'
#####`backup_keep_age`
How long to keep the backup archives for. You can choose seconds, minutes, hours, days, or weeks by specifying the first letter of any of those words (e.g., ‘1w’). Specifying 0 will remove all files.
#####`backup_schedule_hour`
Hour schedule for when to perform backup. Defaults to '5'.
#####`backup_schedule_minute`
Minute schedule for when to perform backup. Defaults to '0'.

##Limitations
* Puppet 3.4+
* Puppet Enterprise

The puppetlabs repositories can be found at:
http://yum.puppetlabs.com/ and http://apt.puppetlabs.com/

* RedHat / CentOS 5/6/7
* Ubuntu 12.04 / 14.04
* Debian 7

We plan to support other Linux distributions and possibly Windows in the near future.

##Development
Please feel free to raise any issues here for bug fixes. We also welcome feature requests. Feel free to make a pull request for anything and we make the effort to review and merge. We prefer with tests if possible.

<a name="testing">
##Testing - How to test the Bitbucket module
Using [puppetlabs_spec_helper](https://github.com/puppetlabs/puppetlabs_spec_helper). Simply run:
```
bundle install && bundle exec rake spec
```
to get results.
```
/usr/bin/ruby1.9.1 -S rspec spec/classes/bitbucket_config_spec.rb spec/classes/bitbucket_facts_spec.rb spec/classes/bitbucket_install_spec.rb spec/classes/bitbucket_service_spec.rb spec/classes/bitbucket_upgrade_spec.rb --color
ldapname is deprecated and will be removed in a future version
.......................

Finished in 2.02 seconds
23 examples, 0 failures
```
Using [Beaker - Puppet Labs cloud enabled acceptance testing tool.](https://github.com/puppetlabs/beaker)

run (Additional yak shaving may be required):
```
BEAKER_set=ubuntu-server-12042-x64 bundle exec rake beaker
BEAKER_set==debian-73-x64 bundle exec rake beaker
BEAKER_set==centos-64-x64 bundle exec rake beaker
```
##Contributors

* Jaco Van Tonder
* Merritt Krakowitzer merritt@krakowitzer.com
* Sebastian Cole
* Geoff Williams
* Bruce Morrison
* Daniel Duwe
* Brian Carpio
* Frank Kleine
