# view

define bind::view($match_clients = false, $match_destinations = false, $match_recursive_only = "no") {

    case $match_recursive_only {
        "yes","no": {}
        default: { fail("Use yes/no for match_recursive_only!") }
    }

    # include new view definition
    concat::fragment {
        "named.conf.view.${name}":
            ensure  => $ensure,
            target  => "/etc/bind/named.conf.view",
            content => "include \"/etc/bind/views/${name}.conf\";\n";
    }

    # define config file
    concat {
        "/etc/bind/views/${name}.conf":
            owner => root,
            group => bind,
            mode  => 644,
            warn  => true,
            notify => Service["bind9"];
    }

    concat::fragment {
        # add header to view config
        "named.conf.view.${name}.header":
            target  => "/etc/bind/views/${name}.conf",
            content => template("bind/view-header.erb"),
            order   => 01;

        # add footer
        "named.conf.view.${name}.footer":
            target  => "/etc/bind/views/${name}.conf",
            content => "};\n",
            order   => 9999;
    }

    # create view directoy
    file {
        "/etc/bind/views/${name}":
            ensure => directory,
            owner  => root,
            group  => bind,
            mode   => 0755,
            require => File["/etc/bind/views"],
            purge   => true,
            force   => true,
            recurse => true,
            source  => "puppet:///modules/bind/empty";
        [ "/etc/bind/views/${name}/zones", "/etc/bind/views/${name}/pri" ]:
            ensure => directory,
            owner  => root,
            group  => bind,
            mode   => 0755,
            require => File["/etc/bind/views/${name}"],
            purge   => true,
            force   => true,
            recurse => true,
            source  => "puppet:///modules/bind/empty";

    }
}
