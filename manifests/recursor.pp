# classes/bind-recursor.pp

class bind::recursor($forwarders) inherits bind::base {

    file {
        "/etc/bind/named.conf.options":
            owner   => root,
            group   => bind,
            mode    => 644,
            content => template("bind/recursor.options.erb"),
            require => Bind::Acl["recursor-acl"];
    }

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

    # add the allow-query part
    concat::fragment {
        "named.conf.view.internal.zone.allow-query":
            target  => "/etc/bind/views/internal.conf",
            content => "  allow-query {\n    recursor-acl;\n  };\n";
    }
}
