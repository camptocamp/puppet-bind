# acl

define bind::acl($ensure = present, $nets = []) {
    common::concatfilepart { "acl ${name}":
        ensure  => $ensure,
        file    => "/etc/bind/named.conf.acl",
        content => template("bind/acl.erb"),
        notify  => Service["bind9"];
    }
}
