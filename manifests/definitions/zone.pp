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
    $view="default",
    $zone_ttl=false,
    $zone_contact=false,
    $zone_serial=false,
    $zone_refresh="3h",
    $zone_retry="1h",
    $zone_expiracy="1w",
    $zone_ns=false,
    $zone_xfers=false,
    $zone_masters=false,
    $zone_name=undef) {

    if $zone_name {
        $_name = $zone_name
    } else {
        $_name = $name
    }

    # define config file
    concat {
        "/etc/bind/zones/${_name}.conf":
            owner  => root,
            group  => bind,
            mode   => 644,
            warn   => true,
            notify => Service["bind9"];
    }
    # include the zone file into the named conf
    concat::fragment {
        "named.conf.view.${view}.zone.${_name}":
            target  => "/etc/bind/views/${view}.conf",
            content => "  include \"/etc/bind/zones/${_name}.conf\";\n";
    }

    if $is_slave {
        if !$zone_masters {
            fail "No master defined for ${_name}!"
        }
        # add slave config to the zone config file
        concat::fragment {
            "named.zone.${_name}":
                target  => "/etc/bind/zones/${_name}.conf",
                content => template("bind/zone-slave.erb");
        }

    ## END of slave
    } else {
        if !$zone_contact {
            fail "No contact defined for ${_name}!"
        }
        if !$zone_ns {
            fail "No ns defined for ${_name}!"
        }
        if !$zone_serial {
            fail "No serial defined for ${_name}!"
        }
        if !$zone_ttl {
            fail "No ttl defined for ${_name}!"
        }

        # add master config to the zone config file
        concat::fragment {
            "named.zone.${_name}":
                target  => "/etc/bind/zones/${_name}.conf",
                content => template("bind/zone-master.erb");
        }

        concat {
            "/etc/bind/pri/${_name}.conf":
                owner  => root,
                group  => bind,
                mode   => 644,
                warn   => "; This file is managed by Puppet. DO NOT EDIT.",
                notify => Service["bind9"];
        }
        concat::fragment {
            "named.zone.${_name}.header":
                target  => "/etc/bind/pri/${_name}.conf",
                content => template("bind/zone-header.erb"),
                order   => 01;
        }
    }
}
