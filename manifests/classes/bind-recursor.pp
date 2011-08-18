# classes/bind-recursor.pp

class bind::recursor inherits bind::base {

    #File["/etc/bind/named.conf.options"] {
    #    source  => "puppet:///modules/bind/named.conf.options.recursor",
    #    require +> Bind::Acl["recursor-acl"]
    #}

    Bind::View["default"] {
        match_clients => [ "!recursor-acl", "any" ],
        require +> Bind::Acl["recursor-acl"]
    }

    bind::view {
        "internal":
            match_clients => [ "recursor-acl" ],
            require       => Bind::Acl["recursor-acl"];
    }
    concat::fragment {
        "named.conf.view.internal.recursion":
            target  => "/etc/bind/views/internal.conf",
            content => "  recursion yes;\n",
            order   => 05;

    }

    Concat::Fragment["named.conf.view.default.zone.default-zones"] {
        target  => "/etc/bind/views/internal.conf"
    }
}
