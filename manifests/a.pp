/*

= Definition: bind::a
Creates an IPv4 record.

Arguments:
 *$zone*:  Bind::Zone name
 *$owner*: owner of the Resource Record
 *$host*:  target of the Resource Record
 *$ttl*:   Time to Live for the Resource Record. Optional.
 *$ptr*:   create the corresponding ptr record (default=false)

*/
define bind::a($ensure=present,
    $zone,
    $owner=false,
    $host,
    $ttl=false,
    $ptr=false) {

  bind::record {$name:
    ensure => $ensure,
    zone   => $zone,
    owner  => $owner,
    host   => $host,
    ttl    => $ttl,
    record_type => 'A',
  }

  if $ptr {
    $subnet = inline_template("<%= host.split('.')[0,3].join('.') %>") 
    $number = inline_template("<%= host.split('.')[3] %>")

    bind::ptr {$host:
      ensure => $ensure,
      zone   => $subnet,
      owner  => $number,
      host   => $owner,
      ttl    => $ttl,
    }
  }
}
