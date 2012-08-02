# = Definition: bind::txt
#
# Creates an IPv4 record.
#
# Arguments:
#  *$zone*:  Bind::Zone name
#  *$owner*: owner of the Resource Record
#  *$text*:  target of the Resource Record
#  *$ttl*:   Time to Live for the Resource Record. Optional.
#
define bind::txt (
  $zone,
  $text,
  $ensure = present,
  $owner  = false,
  $ttl    = false
) {

  bind::record {$name:
    ensure      => $ensure,
    zone        => $zone,
    owner       => $owner,
    host        => $text,
    ttl         => $ttl,
    record_type => 'TXT',
  }

}
