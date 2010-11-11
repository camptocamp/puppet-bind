/*

= Definition: bind::mx
Creates an MX record.

Arguments:
 *$zone*:     Bind::Zone name
 *$owner*:    owner of the Resource Record
 *$priority*: MX record priority
 *$host*:     target of the Resource Record
 *$ttl*:      Time to Live for the Resource Record. Optional.

*/
define bind::mx($ensure=present,
    $zone,
    $owner,
    $priority,
    $host,
    $ttl=false) {

  common::concatfilepart{"bind.${name}":
    file    => "/etc/bind/pri/${zone}",
    ensure  => $ensure,
    notify  => Service["bind9"],
    content => template("bind/mx-record.erb"),
    require => [Bind::Zone[$zone], Bind::A[$host]],
  }
}

