# = Definition: bind::zone
#
# Creates a valid Bind9 zone.
#
# Arguments:
#  *$zone_type*: String. Specify if the zone is master/slave/forward. Default master
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
#  *$zone_forwarders*: IPs. Valid forwarders for this zone (forward only)
#  *$zone_origin*: The origin of the zone
#  *$zone_notify*: IPs to use for also-notify entry
#
define bind::zone (
  $ensure          = present,
  $is_dynamic      = false,
  $allow_update    = [],
  $transfer_source = undef,
  $view            = 'default',
  $zone_type       = 'master',
  $zone_ttl        = undef,
  $zone_contact    = undef,
  $zone_serial     = undef,
  $zone_refresh    = '3h',
  $zone_retry      = '1h',
  $zone_expiracy   = '1w',
  $zone_ns         = [],
  $zone_xfers      = undef,
  $zone_masters    = undef,
  $zone_forwarders = undef,
  $zone_origin     = undef,
  $zone_notify     = undef,
  $is_slave        = false,
) {

  include ::bind::params

  validate_string($ensure)
  validate_re($ensure, ['present', 'absent'],
              "\$ensure must be either 'present' or 'absent', got '${ensure}'")

  validate_bool($is_slave)
  validate_bool($is_dynamic)
  validate_array($allow_update)
  validate_string($transfer_source)
  validate_string($view)
  validate_string($zone_type)
  validate_string($zone_ttl)
  validate_string($zone_contact)
  validate_string($zone_serial)
  validate_string($zone_refresh)
  validate_string($zone_retry)
  validate_string($zone_expiracy)
  validate_array($zone_ns)

  validate_string($zone_origin)

  $_view = regsubst($view, '\s', '-', 'G')

  # add backwards support for is_slave parameter 
  if ($is_slave) and ($zone_type == 'master') {
    warning('$is_slave is deprecated. You should set $zone_type = \'slave\'')
    $int_zone_type = 'slave'
  } else {
    $int_zone_type = $zone_type
  }

  if ($int_zone_type != 'master' and $is_dynamic) {
    fail "Zone '${name}' cannot be ${int_zone_type} AND dynamic!"
  }

  if ($transfer_source and $int_zone_type != 'slave') {
    fail "Zone '${name}': transfer_source can be set only for slave zones!"
  }

  case $ensure {
    'present': {
      concat::fragment {"${_view}.zone.${name}":
        target  => "${bind::params::views_directory}/${_view}.zones",
        content => "include \"${bind::params::zones_directory}/${name}.conf\";\n",
        notify  => Exec['reload bind9'],
        require => Package['bind9'],
      }
      concat {"${bind::params::zones_directory}/${name}.conf":
        owner  => root,
        group  => root,
        mode   => '0644',
        notify => Exec['reload bind9'],
      }
      concat::fragment {"bind.zones.${name}":
        target  => "${bind::params::zones_directory}/${name}.conf",
        notify  => Exec['reload bind9'],
        require => Package['bind9'],
      }

      case $int_zone_type {
        'master': {
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
              target  => $conf_file,
              order   => '01',
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
        'slave': {
          Concat::Fragment["bind.zones.${name}"] {
            content => template('bind/zone-slave.erb'),
          }

        }
        'forward': {
          Concat::Fragment["bind.zones.${name}"] {
            content => template('bind/zone-forward.erb'),
          }
        }
        default: { fail("Zone type '${int_zone_type}' not supported.") }
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
