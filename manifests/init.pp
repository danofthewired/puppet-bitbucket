# == Class: bitbucket
#
# This modules installs Atlassian bitbucket.
#
class bitbucket(

  # JVM Settings
  $javahome     = undef,
  $jvm_xms      = '256m',
  $jvm_xmx      = '1024m',
  $jvm_permgen  = '256m',
  $jvm_optional = '-XX:-HeapDumpOnOutOfMemoryError',
  $jvm_support_recommended_args = '',
  $java_opts    = '',
  $umask        = undef,

  # Bitbucket Settings
  $version      = '4.2.0',
  $product      = 'bitbucket',
  $format       = 'tar.gz',
  $installdir   = '/opt/bitbucket',
  $homedir      = '/home/bitbucket',
  $context_path = '',
  $tomcat_port  = 7990,

  # User and Group Management Settings
  $manage_usr_grp = true,
  $user           = 'atlbitbucket',
  $group          = 'atlbitbucket',
  $uid            = undef,
  $gid            = undef,

  # Bitbucket 4.2.0 initialization configurations
  $display_name  = 'bitbucket',
  $base_url      = "https://${::fqdn}",
  $license       = '',
  $sysadmin_username = 'admin',
  $sysadmin_password = 'bitbucket',
  $sysadmin_name  = 'Bitbucket Admin',
  $sysadmin_email = '',
  $config_properties = {},

  # Database Settings
  $dbuser       = 'bitbucket',
  $dbpassword   = 'password',
  $dburl        = 'jdbc:postgresql://localhost:5432/bitbucket',
  $dbdriver     = 'org.postgresql.Driver',

  # Misc Settings
  $download_url  = 'https://downloads.atlassian.com/software/stash/downloads',
  $checksum     = undef,

  # Backup Settings
  $backup_ensure          = 'present',
  $backupclient_url       = 'https://maven.atlassian.com/content/groups/public/com/atlassian/bitbucket/server/backup/bitbucket-backup-distribution',
  $backup_format          = 'zip',
  $backupclient_version   = '2.0.2',
  $backup_home            = '/opt/bitbucket-backup',
  $backupuser             = 'admin',
  $backuppass             = 'password',
  $backup_schedule_hour   = '5',
  $backup_schedule_minute = '0',
  $backup_keep_age        = '4w',

  # Manage service
  $service_manage = true,
  $service_ensure = running,
  $service_enable = true,

  # Reverse https proxy
  $proxy = {},

  # Command to stop bitbucket in preparation to updgrade. # This is configurable
  # incase the bitbucket service is managed outside of puppet. eg: using the
  # puppetlabs-corosync module: 'crm resource stop bitbucket && sleep 15'
  $stop_bitbucket = 'service bitbucket stop && sleep 15',

  # Choose whether to use nanliu-staging, or puppet-archive
  $deploy_module = 'archive',

) {

  validate_hash($config_properties)

  include ::bitbucket::params

  Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }

  $webappdir    = "${installdir}/atlassian-${product}-${version}"

  if $::bitbucket_version {
    # If the running version of bitbucket is less than the expected version of bitbucket
    # Shut it down in preparation for upgrade.
    if versioncmp($version, $::bitbucket_version) > 0 {
      notify { 'Attempting to upgrade bitbucket': }
      exec { $stop_bitbucket: }
      if versioncmp($version, '3.2.0') > 0 {
        exec { "rm -f ${homedir}/stash-config.properties": }
      }
    }
  }

  anchor { 'bitbucket::start':
  } ->
  class { '::bitbucket::install': webappdir => $webappdir, } ->
  class { '::bitbucket::config': } ~>
  class { '::bitbucket::service': } ->
  class { '::bitbucket::backup': } ->
  anchor { 'bitbucket::end': }

}
