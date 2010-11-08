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
}
