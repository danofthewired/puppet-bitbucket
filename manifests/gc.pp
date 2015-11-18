# == Class: bitbucket::gc
#
# Class to run git gc on bitbucket repo's at regular intervals
#
# === Parameters
#
# [*ensure*]
#   enable or disable cron job to run git garabage collection.
# [*path*]
#   Default path to install script to.
# [*weekday*]
#   Day of the week to run script on, default is Sunday at midnight.
#
# === Examples
#
# class { 'bitbucket::gc': }
#
class bitbucket::gc(
  $ensure  = 'present',
  $path    = '/usr/local/bin/git-gc.sh',
  $minute  = 0,
  $hour    = 0,
  $weekday = 'Sunday',
  $user    = $bitbucket::user,
  $homedir = $bitbucket::homedir,
  ) {

  include ::bitbucket::params

  if versioncmp($::bitbucket_version, '3.2') < 0 {
    $shared = ''
  } else {
    $shared = '/shared'
  }

  file { $path:
    ensure  => $ensure,
    content => template('bitbucket/git-gc.sh.erb'),
    mode    => '0755',
  } ->

  cron { 'git-gc-bitbucket':
    ensure  => $ensure,
    command => "${path} &>/dev/null",
    user    => $user,
    minute  => $minute,
    hour    => $hour,
    weekday => $weekday,
  }

}
