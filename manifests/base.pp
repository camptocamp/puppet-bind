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
  }

  package {'bind9':
    ensure => present,
  }

  service {'bind9':
    ensure  => running,
    enable  => true,
    require => Package['bind9'],
  }

  file {'/etc/bind/zones':
    ensure  => directory,
    owner   => root,
    group   => root,
    mode    => '0755',
    purge   => true,
    force   => true,
    recurse => true,
    source  => 'puppet:///modules/bind/empty',
    require => Package['bind9'],
  }

}
