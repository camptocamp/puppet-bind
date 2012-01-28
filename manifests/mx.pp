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
    $view="default",
    $owner=false,
    $priority,
    $host,
    $ttl=false) {

    if $owner {
        $_owner = $owner
    } else {
        $_owner = $name
    }

    concat::fragment {
        "named.view.${view}.zone.${zone}.${name}":
            target  => "/etc/bind/views/${view}/pri/${zone}.conf",
            content => template("bind/mx-record.erb"),
            order   => 05;
    }
}

