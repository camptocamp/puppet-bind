define bind::aaaa($ensure=present,
    $zone,
    $owner,
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
