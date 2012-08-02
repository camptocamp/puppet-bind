# = Definition: bind::ptr
#
# Creates a PTR record.
#
# Arguments:
#  *$zone*:  Bind::Zone name
#  *$owner*: number of the Resource Record
#  *$host*:  target of the Resource Record
#  *$ttl*:   Time to Live for the Resource Record. Optional.
#
define bind::ptr(
  $zone,
  $host,
  $ensure = present,
  $owner  = false,
  $ttl    = false
) {

  bind::record {$name:
    ensure      => $ensure,
    zone        => $zone,
    owner       => $owner,
    host        => $host,
    ttl         => $ttl,
    record_type => 'PTR',
  }

}
