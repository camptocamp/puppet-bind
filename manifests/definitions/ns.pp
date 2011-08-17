/*

= Definition: bind::ns
Creates an NS record.

Arguments:
 *$zone*:  Bind::Zone name
 *$owner*: owner of the Resource Record
 *$host*:  target of the Resource Record
 *$ttl*:   Time to Live for the Resource Record. Optional.

*/
define bind::ns($ensure=present,
    $zone,
    $owner=false,
    $host,
    $ttl=false,
    $order="01") {

  bind::record {$name:
    ensure => $ensure,
    zone   => $zone,
    owner  => $owner,
    host   => $host,
    ttl    => $ttl,
    order  => $order,
    record_type => 'NS',
  }
}
