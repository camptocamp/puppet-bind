# acl

define bind::acl($ensure = present, $nets = []) {
    concat::fragment {
        "named.conf.acl.${name}":
            ensure  => $ensure,
            target  => "/etc/bind/named.conf.acl",
            content => template("bind/acl.erb")
    }
}
