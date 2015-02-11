# = Class: bind::base
#
# Declares some basic resources.
# You should NOT include this class as is, as it won't work at all!
# Please refer to Class['bind'].
#
class bind::base inherits bind::params {

  concat {"${bind::params::config_base_dir}/${bind::params::named_local_name}":
    owner => root,
    group => root,
    mode  => '0644',
    force => true,
  }

  file_line {'include local':
    ensure  => present,
    line    => "include \"${bind::params::config_base_dir}/${bind::params::named_local_name}\";",
    path    => "${bind::params::config_base_dir}/${bind::params::named_conf_name}",
    require => Package['bind9'],
    notify  => Exec['reload bind9'],
  }

  package {$bind::params::package_name:
    ensure => present,
    alias  => 'bind9',
  }

  service { 'bind9':
    ensure    => running,
    name      => $bind::params::service_name,
    enable    => true,
    require   => Package['bind9'],
    restart   => $bind::params::service_restart,
    hasstatus => $bind::params::service_has_status,
    pattern   => $bind::params::service_pattern,
  }

  exec {'reload bind9':
    command     => $bind::params::service_restart,
    onlyif      => "named-checkconf -jz ${bind::params::config_base_dir}/${bind::params::named_conf_name}",
    refreshonly => true,
  }

  file {$bind::params::zones_directory:
    ensure  => directory,
    owner   => root,
    group   => root,
    mode    => '0755',
    purge   => true,
    force   => true,
    recurse => true,
    require => Package['bind9'],
  }

  file {$bind::params::pri_directory:
    ensure  => directory,
    owner   => root,
    group   => root,
    mode    => '0755',
    purge   => true,
    force   => true,
    recurse => true,
    require => Package['bind9'],
  }

  file {$bind::params::keys_directory:
    ensure  => directory,
    owner   => root,
    group   => $bind::params::bind_group,
    mode    => '0750',
    purge   => true,
    force   => true,
    recurse => true,
    require => Package['bind9'],
  }

  file {$bind::params::dynamic_directory:
    ensure  => directory,
    owner   => root,
    group   => $bind::params::bind_group,
    mode    => '0775',
    require => Package['bind9'],
  }

}
