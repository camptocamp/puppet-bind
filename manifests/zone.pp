# = Definition: bind::zone
#
# Creates a valid Bind9 zone.
#
# Arguments:
#  *$is_slave*: Boolean. Is your zone a slave or a master? Default false
#  *$zone_ttl*: Time period. Time to live for your zonefile (master only)
#  *$zone_contact*: Valid contact record (master only)
#  *$zone_serial*: Integer. Zone serial (master only)
#  *$zone_refresh*: Time period. Time between each slave refresh (master only)
#  *$zone_retry*: Time period. Time between each slave retry (master only)
#  *$zone_expiracy*: Time period. Slave expiracy time (master only)
#  *$zone_ns*: Valid NS for this zone (master only)
#  *$zone_xfers*: IPs. Valid xfers for zone (master only)
#  *$zone_masters*: IPs. Valid master for this zone (slave only)
#  *$zone_origin*: The origin of the zone
#
define bind::zone (
  $ensure        = present,
  $is_slave      = false,
  $zone_ttl      = '',
  $zone_contact  = '',
  $zone_serial   = '',
  $zone_refresh  = '3h',
  $zone_retry    = '1h',
  $zone_expiracy = '1w',
  $zone_ns       = '',
  $zone_xfers    = '',
  $zone_masters  = '',
  $zone_origin   = '',
) {

  validate_string($ensure)
  validate_re($ensure, ['present', 'absent'],
              "\$ensure must be either 'present' or 'absent', got '${ensure}'")

  validate_bool($is_slave)
  validate_string($zone_ttl)
  validate_string($zone_contact)
  validate_string($zone_serial)
  validate_string($zone_refresh)
  validate_string($zone_retry)
  validate_string($zone_expiracy)
  validate_string($zone_ns)
  validate_string($zone_xfers)
  validate_string($zone_masters)
  validate_string($zone_origin)

  concat::fragment {"named.local.zone.${name}":
    ensure  => $ensure,
    target  => '/etc/bind/named.conf.local',
    content => "include \"/etc/bind/zones/${name}.conf\";\n",
    notify  => Service['bind9'],
    require => Package['bind9'],
  }

  case $ensure {
    present: {
      concat {"/etc/bind/zones/${name}.conf":
        owner => root,
        group => root,
        mode  => '0644',
      }
      concat::fragment {"bind.zones.${name}":
        ensure  => $ensure,
        target  => "/etc/bind/zones/${name}.conf",
        notify  => Service['bind9'],
        require => Package['bind9'],
      }


      if $is_slave {
        validate_re($zone_masters, '\S+', "Wrong master value for ${name}!")
        Concat::Fragment["bind.zones.${name}"] {
          content => template('bind/zone-slave.erb'),
        }
## END of slave
      } else {
        validate_re($zone_contact, '\S+', "Wrong contact value for ${name}!")
        validate_re($zone_ns, '\S+', "Wrong ns value for ${name}!")
        validate_re($zone_serial, '\d+', "Wrong serial value for ${name}!")
        validate_re($zone_ttl, '\d+', "Wrong ttl value for ${name}!")

        concat {"/etc/bind/pri/${name}.conf":
          owner => root,
          group => root,
          mode  => '0644',
        }

        Concat::Fragment["bind.zones.${name}"] {
          content => template('bind/zone-master.erb'),
        }

        concat::fragment {"00.bind.${name}":
          ensure  => $ensure,
          target  => "/etc/bind/pri/${name}.conf",
          content => template('bind/zone-header.erb'),
          require => Package['bind9'],
        }

        file {"/etc/bind/pri/${name}.conf.d":
          ensure  => absent,
          mode    => '0700',
          purge   => true,
          recurse => true,
          backup  => false,
          force   => true,
        }
      }
    }
    absent: {
      file {"/etc/bind/pri/${name}.conf":
        ensure => absent,
      }
      file {"/etc/bind/zones/${name}.conf":
        ensure => absent,
      }
    }
    default: {}
  }
}
