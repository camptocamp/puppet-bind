# = Definition: bind::zone
#
# Creates a valid Bind9 zone.
#
# Arguments:
#  *$is_slave*: Boolean. Is your zone a slave or a master? Default false
#  *$transfer_source*: IPv4 address. Source IP to bind to when requesting a transfer (slave only)
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
#  *$zone_notify*: IPs to use for also-notify entry
#
define bind::zone (
  $ensure          = present,
  $is_dynamic      = false,
  $is_slave        = false,
  $allow_update    = [],
  $transfer_source = undef,
  $zone_ttl        = undef,
  $zone_contact    = undef,
  $zone_serial     = undef,
  $zone_refresh    = '3h',
  $zone_retry      = '1h',
  $zone_expiracy   = '1w',
  $zone_ns         = [],
  $zone_xfers      = undef,
  $zone_masters    = undef,
  $zone_origin     = undef,
  $zone_notify     = undef,
) {

  include ::bind::params

  validate_string($ensure)
  validate_re($ensure, ['present', 'absent'],
              "\$ensure must be either 'present' or 'absent', got '${ensure}'")

  validate_bool($is_dynamic)
  validate_bool($is_slave)
  validate_array($allow_update)
  validate_string($transfer_source)
  validate_string($zone_ttl)
  validate_string($zone_contact)
  validate_string($zone_serial)
  validate_string($zone_refresh)
  validate_string($zone_retry)
  validate_string($zone_expiracy)
  validate_array($zone_ns)
  validate_string($zone_origin)

  if ($is_slave and $is_dynamic) {
    fail "Zone '${name}' cannot be slave AND dynamic!"
  }

  if ($transfer_source and ! $is_slave) {
    fail "Zone '${name}': transfer_source can be set only for slave zones!"
  }

  concat::fragment {"named.local.zone.${name}":
    ensure  => $ensure,
    target  => "${bind::params::config_base_dir}/${bind::params::named_local_name}",
    content => "include \"${bind::params::zones_directory}/${name}.conf\";\n",
    notify  => Exec['reload bind9'],
    require => Package['bind9'],
  }

  case $ensure {
    'present': {
      concat {"${bind::params::zones_directory}/${name}.conf":
        owner  => root,
        group  => root,
        mode   => '0644',
        notify => Exec['reload bind9'],
      }
      concat::fragment {"bind.zones.${name}":
        ensure  => $ensure,
        target  => "${bind::params::zones_directory}/${name}.conf",
        notify  => Exec['reload bind9'],
        require => Package['bind9'],
      }


      if $is_slave {
        Concat::Fragment["bind.zones.${name}"] {
          content => template('bind/zone-slave.erb'),
        }
## END of slave
      } else {
        validate_re($zone_contact, '^\S+$', "Wrong contact value for ${name}!")
        validate_slength($zone_ns, 255, 3)
        validate_re($zone_serial, '^\d+$', "Wrong serial value for ${name}!")
        validate_re($zone_ttl, '^\d+$', "Wrong ttl value for ${name}!")

        $conf_file = $is_dynamic? {
          true    => "${bind::params::dynamic_directory}/${name}.conf",
          default => "${bind::params::pri_directory}/${name}.conf",
        }

        $require = $is_dynamic? {
          true    => Bind::Key[$allow_update],
          default => undef,
        }

        if $is_dynamic {
          file {$conf_file:
            owner   => root,
            group   => $bind::params::bind_group,
            mode    => '0664',
            replace => false,
            content => template('bind/zone-header.erb'),
            notify  => Exec['reload bind9'],
            require => [Package['bind9'], $require],
          }
        } else {
          concat {$conf_file:
            owner   => root,
            group   => $bind::params::bind_group,
            mode    => '0664',
            notify  => Exec['reload bind9'],
            require => Package['bind9'],
          }

          concat::fragment {"00.bind.${name}":
            ensure  => $ensure,
            target  => $conf_file,
            content => template('bind/zone-header.erb'),
          }
        }

        Concat::Fragment["bind.zones.${name}"] {
          content => template('bind/zone-master.erb'),
        }

        file {"${bind::params::pri_directory}/${name}.conf.d":
          ensure  => absent,
        }
      }
    }
    'absent': {
      file {"${bind::params::pri_directory}/${name}.conf":
        ensure => absent,
      }
      file {"${bind::params::zones_directory}/${name}.conf":
        ensure => absent,
      }
    }
    default: {}
  }
}
