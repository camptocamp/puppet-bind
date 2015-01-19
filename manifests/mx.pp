# = Definition: bind::mx
# Creates an MX record.
#
# Arguments:
#  *$zone*:     Bind::Zone name
#  *$owner*:    owner of the Resource Record
#  *$priority*: MX record priority
#  *$host*:     target of the Resource Record
#  *$ttl*:      Time to Live for the Resource Record. Optional.
#
define bind::mx (
  $zone,
  $host,
  $priority,
  $ensure = present,
  $owner  = undef,
  $ttl    = undef,
) {

  validate_string($ensure)
  validate_re($ensure, ['present', 'absent'],
              "\$ensure must be either 'present' or 'absent', got '${ensure}'")

  validate_string($zone)
  validate_string($host)
  validate_string($priority)
  validate_string($owner)
  validate_string($ttl)

  $_owner = $owner ? {
    ''      => $name,
    default => $owner
  }

  concat::fragment {"bind.${name}":
    ensure  => $ensure,
    target  => "${bind::params::pri_directory}/${zone}.conf",
    content => template('bind/mx-record.erb'),
    notify  => Service['bind9'],
  }

}

