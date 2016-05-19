
# == Class: bitbucket::backup
#
# This installs the bitbucket backup client
#
class bitbucket::backup(
  $manage_backup        = $bitbucket::manage_backup,
  $ensure               = $bitbucket::backup_ensure,
  $schedule_hour        = $bitbucket::backup_schedule_hour,
  $schedule_minute      = $bitbucket::backup_schedule_minute,
  $backupuser           = $bitbucket::backupuser,
  $backuppass           = $bitbucket::backuppass,
  $version              = $bitbucket::backupclient_version,
  $product              = $bitbucket::product,
  $backup_format        = $bitbucket::backup_format,
  $homedir              = $bitbucket::homedir,
  $user                 = $bitbucket::user,
  $group                = $bitbucket::group,
  $deploy_module        = $bitbucket::deploy_module,
  $download_url         = $bitbucket::backupclient_url,
  $backup_home          = $bitbucket::backup_home,
  $javahome             = $bitbucket::javahome,
  $keep_age             = $bitbucket::backup_keep_age,
  $manage_usr_grp       = $bitbucket::manage_usr_grp,
  ) {

  if $manage_backup {
    $appdir = "${backup_home}/${product}-backup-client-${version}"

    file { $backup_home:
      ensure => 'directory',
      owner  => $user,
      group  => $group,
    }
    file { "${backup_home}/archives":
      ensure => 'directory',
      owner  => $user,
      group  => $group,
    }

    $file = "${product}-backup-distribution-${version}.${backup_format}"

    file { $appdir:
      ensure => 'directory',
      owner  => $user,
      group  => $group,
    }

    file { '/var/tmp/downloadurl':
      content => "${download_url}/${version}/${file}",
    }

    case $deploy_module {
      'staging': {
        require staging
        staging::file { $file:
          source  => "${download_url}/${version}/${file}",
          timeout => 1800,
        } ->
        staging::extract { $file:
          target  => $appdir,
          creates => "${appdir}/lib",
          strip   => 1,
          user    => $user,
          group   => $group,
          require => File[$appdir],
        }

        if $manage_usr_grp {
          User[$user] -> Staging::Extract[$file]
        }
      }
      'archive': {
        archive { "/tmp/${file}":
          ensure       => present,
          extract      => true,
          extract_path => $backup_home,
          source       => "${download_url}/${version}/${file}",
          user         => $user,
          group        => $group,
          creates      => "${appdir}/lib",
          cleanup      => true,
          before       => File[$appdir],
        }
      }
      default: {
        fail('deploy_module parameter must equal "archive" or staging""')
      }
    }

    if $javahome {
      $java_bin = "${javahome}/bin/java"
    } else {
      $java_bin = '/usr/bin/java'
    }

    # Enable Cronjob
    $backup_cmd = "${java_bin} -Dbitbucket.password=\"${backuppass}\" -Dbitbucket.user=\"${backupuser}\" -Dbitbucket.baseUrl=\"http://localhost:7990\" -Dbitbucket.home=${homedir} -Dbackup.home=${backup_home}/archives -jar ${appdir}/bitbucket-backup-client.jar"

    cron { 'Backup Bitbucket':
      ensure  => $ensure,
      command => $backup_cmd,
      user    => $user,
      hour    => $schedule_hour,
      minute  => $schedule_minute,
    }

    tidy { 'remove_old_archives':
      path    => "${backup_home}/archives",
      age     => $keep_age,
      matches => '*.tar',
      type    => 'mtime',
      recurse => 2,
    }
  }

}
