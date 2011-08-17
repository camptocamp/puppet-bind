/*

= Definition: bind::aaaa
Creates an IPv6 AAAA record.

Arguments:
 *$zone*:  Bind::Zone name
 *$owner*: owner of the Resource Record
 *$host*:  target of the Resource Record
 *$ttl*:   Time to Live for the Resource Record. Optional.

*/
define bind::aaaa($ensure=present,
    $zone,
    $owner=false,
    $host,
    $ttl=false) {

  bind::record {$name:
    ensure => $ensure,
    zone   => $zone,
    owner  => $owner,
    host   => $host,
    ttl   => $ttl,
    record_type => 'AAAA',
  }

}
