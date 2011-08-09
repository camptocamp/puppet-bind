# classes/bind-recursor.pp

class bind::recursor inherits bind::base {

    File["/etc/bind/named.conf.options"] {
        source  => "puppet:///modules/bind/named.conf.options.recursor",
        require +> Bind::Acl["recursor-acl"]
    }
}
