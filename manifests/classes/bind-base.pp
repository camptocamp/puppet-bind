/*

= Class: bind::base

Declares some basic resources.
You should NOT include this class as is, as it won't work at all!
Please refer to Class["bind"].

*/
class bind::base {
  package {"bind9":
    ensure => present,
  }

  service {"bind9":
    ensure  => running,
    enable  => true,
    require => Package["bind9"],
  }

  file {["/etc/bind/pri", "/etc/bind/zones"]:
    ensure => directory,
    owner  => root,
    group  => root,
    mode   => 0755,
    require => Package["bind9"],
    purge   => true,
    force   => true,
    recurse => true,
    source  => "puppet:///modules/bind/empty",
  }
  file { "/etc/bind/named.conf.options":
    ensure  => present,
    owner   => root,
    group   => bind,
    mode    => 644,
    notify  => Service["bind9"],
    source  => "puppet:///modules/bind/named.conf.options.normal";
  }

  # include acls
  common::concatfilepart { "named.local.acl":
    ensure  => $ensure,
    file    => "/etc/bind/named.conf.local",
    content => "include \"/etc/bind/named.conf.acl\";\n",
    notify  => Service["bind9"];
  }
  common::concatfilepart {
    "00-bind.acls.head":
      file    => "/etc/bind/named.conf.acl",
      ensure  => present,
      content => "# file managed by puppet\n",
      notify  => Service["bind9"];
  }
}
