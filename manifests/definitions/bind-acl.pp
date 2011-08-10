# acl

define bind::acl($ensure = present, $nets = []) {
    common::concatfilepart { "acl ${name}":
        ensure  => $ensure,
        file    => "/etc/bind/named.conf.local",
        content => "include \"/etc/bind/acl.${name}.conf\";\n",
        notify  => Service["bind9"];
    }

    file { "/etc/bind/acl.${name}.conf":
        ensure  => $ensure,
        owner   => root,
        group   => bind,
        mode    => 644,
        content => template("bind/acl.erb"),
        notify  => Service["bind9"];
    }
}
