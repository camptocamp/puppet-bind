define bind::record($ensure=present,
    $zone,
    $owner,
    $host,
    $record_type,
    $record_class='IN',
    $ttl=false) {

  common::concatfilepart {"${zone}.${record_type}.${name}":
    ensure  => $ensure,
    file    => "/etc/bind/pri/${zone}.conf",
    content => template("bind/default-record.erb"),
  }
}
