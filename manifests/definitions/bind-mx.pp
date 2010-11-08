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
    require => Bind::Zone[$zone],
  }
}

