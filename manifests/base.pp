# = Class: bind::base
#
# Declares some basic resources.
# You should NOT include this class as is, as it won't work at all!
# Please refer to Class['bind'].
#
class bind::base {

  include concat::setup

  concat {'/etc/bind/named.conf.local':
    owner => root,
    group => root,
    mode  => '0644',
    force => true,
  }

  package {'bind9':
    ensure => present,
  }

  service {'bind9':
    ensure  => running,
    enable  => true,
    require => Package['bind9'],
  }

  exec {'reload bind9':
    command     => 'service bind9 reload',
    onlyif      => 'named-checkconf -jz /etc/bind/named.conf',
    refreshonly => true,
  }

  file {'/etc/bind/zones':
    ensure  => directory,
    owner   => root,
    group   => root,
    mode    => '0755',
    purge   => true,
    force   => true,
    recurse => true,
    require => Package['bind9'],
  }

  file {'/etc/bind/pri':
    ensure  => directory,
    owner   => root,
    group   => root,
    mode    => '0755',
    purge   => true,
    force   => true,
    recurse => true,
    require => Package['bind9'],
  }

  file {'/etc/bind/keys':
    ensure  => directory,
    owner   => root,
    group   => bind,
    mode    => '0750',
    purge   => true,
    force   => true,
    recurse => true,
    require => Package['bind9'],
  }

  file {'/etc/bind/dynamic':
    ensure  => directory,
    owner   => root,
    group   => bind,
    mode    => '0775',
    purge   => true,
    force   => true,
    recurse => true,
    require => Package['bind9'],
  }

}
