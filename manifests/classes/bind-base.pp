/*

= Class: bind::base

Declares some basic resources.
You should NOT include this class as is, as it won't work at all!
Please refer to Class["bind"].

*/
class bind::base {
    package {
        "bind9":
            ensure => present,
    }

    include concat::setup

    service {
        "bind9":
            ensure  => running,
            enable  => true,
            require => Package["bind9"],
    }

    file {
        ["/etc/bind/pri", "/etc/bind/zones"]:
            ensure => directory,
            owner  => root,
            group  => root,
            mode   => 0755,
            require => Package["bind9"],
            purge   => true,
            force   => true,
            recurse => true,
            source  => "puppet:///modules/bind/empty";
        "/etc/bind/named.conf.options":
            ensure  => present,
            owner   => root,
            group   => bind,
            mode    => 644,
            notify  => Service["bind9"],
            source  => "puppet:///modules/bind/named.conf.options.normal";
    }

    # include acls
    concat {
        "/etc/bind/named.conf.local":
            owner  => root,
            group  => bind,
            mode   => 644,
            warn   => true,
            notify => Service["bind9"];
    }
    concat::fragment {
        "named.conf.acl":
            target  => "/etc/bind/named.conf.local",
            content => "include \"/etc/bind/named.conf.acl\";\n";
    }
    concat {
        "/etc/bind/named.conf.acl":
            owner  => root,
            group  => bind,
            mode   => 644,
            warn   => true,
            notify => Service["bind9"];
    }

    # include views
    concat::fragment {
        "named.conf.view":
            target  => "/etc/bind/named.conf.local",
            content => "include \"/etc/bind/named.conf.view\";\n";
    }
    concat {
        "/etc/bind/named.conf.view":
            owner  => root,
            group  => bind,
            mode   => 644,
            warn   => true,
            force  => true,
            notify => Service["bind9"];
    }
}
