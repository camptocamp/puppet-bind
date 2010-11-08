define bind::zone($ensure=present,
    $is_slave=false,
    $zone_ttl=false,
    $zone_contact=false,
    $zone_serial=false,
    $zone_refresh="3h",
    $zone_retry="1h",
    $zone_expiracy="1w",
    $zone_ns=false,
    $zone_xfers=false,
    $zone_masters=false) {

  common::concatfilepart {"bind.zones.${name}":
    ensure => $ensure,
    notify => Service["bind9"],
    file   => "/etc/bind/zones/${name}.conf",
  }

  common::concatfilepart {"named.local.zone.${name}":
    ensure  => $ensure,
    notify  => Service["bind9"],
    file    => "/etc/bind/named.conf.local",
    content => "include \"/etc/bind/zones/${name}.conf\";\n",
  }

  if $is_slave {
    if !$zone_masters {
      fail "No master defined for ${name}!"
    }
    Common::Concatfilepart["bind.zones.${name}"] {
      content => template("bind/zone-slave.erb"),
    }
## END of slave
  } else {
    if !$zone_contact {
      fail "No contact defined for ${name}!"
    }
    if !$zone_ns {
      fail "No ns defined for ${name}!"
    }
    if !$zone_serial {
      fail "No serial defined for ${name}!"
    }
    if !$zone_ttl {
      fail "No ttl defined for ${name}!"
    }

    Common::Concatfilepart["bind.zones.${name}"] {
      content => template("bind/zone-master.erb"),
    }

    common::concatfilepart {"bind.00.${name}":
      ensure => $ensure,
      file   => "/etc/bind/pri/${name}.conf",
      content => template("bind/zone-header.erb"),
    }
  }
}
