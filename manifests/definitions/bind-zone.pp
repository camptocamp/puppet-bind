/*

= Definition: bind::zone
Creates a valid Bind9 zone.

Arguments:
  *$is_slave*:          Boolean. Is your zone a slave or a master? Default false
  *$zone_ttl*:          Time period. Time to live for your zonefile (master only)
  *$zone_contact*:      Valid contact record (master only)
  *$zone_serial*:       Integer. Zone serial (master only)
  *$zone_refresh*:      Time period. Time between each slave refresh (master only)
  *$zone_retry*:        Time period. Time between each slave retry (master only)
  *$zone_expiracy*:     Time period. Slave expiracy time (master only)
  *$zone_ns*:           Valid NS for this zone (master only)
  *$zone_xfers*:        IPs. Valid xfers for zone (master only)
  *$zone_masters*:      IPs. Valid master for this zone (slave only)

*/
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
