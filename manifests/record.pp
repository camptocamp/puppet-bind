# = Definition: bind::record
#
# Helper to create any record you want (but NOT MX, please refer to Bind::Mx)
#
# Arguments:
#  *$zone*:        Bind::Zone name
#  *$owner*:       owner of the Resource Record
#  *$host*:        target of the Resource Record
#  *$record_type°:  resource record type
#  *$record_class*: resource record class. Default "IN".
#  *$ttl*:          Time to Live for the Resource Record. Optional.
#
define bind::record (
  $zone,
  $host,
  $record_type,
  $ensure       = present,
  $owner        = false,
  $record_class = 'IN',
  $ttl          = false
) {

  if $owner {
    $_owner = $owner
  } else {
    $_owner = $name
  }

  concat::fragment {"${zone}.${record_type}.${name}":
    ensure  => $ensure,
    target  => "/etc/bind/pri/${zone}.conf",
    content => template('bind/default-record.erb'),
    notify  => Service['bind9'],
  }

}
