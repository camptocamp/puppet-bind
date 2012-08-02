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
  $owner  = false,
  $ttl    = false
) {

  if $owner {
    $_owner = $owner
  } else {
    $_owner = $name
  }

  concat::fragment {"bind.${name}":
    ensure  => $ensure,
    target  => "/etc/bind/pri/${zone}.conf",
    content => template('bind/mx-record.erb'),
    notify  => Service['bind9'],
    require => [Bind::Zone[$zone], Bind::A[$host]],
  }

}

