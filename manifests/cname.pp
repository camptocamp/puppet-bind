/*

= Definition: bind::cname
Creates a CNAME record.

Arguments:
 *$zone*:  Bind::Zone name
 *$owner*: owner of the Resource Record
 *$host*:  target of the Resource Record
 *$ttl*:   Time to Live for the Resource Record. Optional.

*/
define bind::cname($ensure=present,
    $zone,
    $owner=false,
    $host,
    $ttl=false) {

  bind::record {$name:
    ensure => $ensure,
    zone   => $zone,
    owner  => $owner,
    host   => $host,
    ttl    => $ttl,
    record_type => 'CNAME',
  }
}
