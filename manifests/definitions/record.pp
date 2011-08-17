/*

= Definition: bind::record
Helper to create any record you want (but NOT MX, please refer to Bind::Mx)

Arguments:
 *$zone*:        Bind::Zone name
 *$owner*:       owner of the Resource Record
 *$host*:        target of the Resource Record
 *$record_type°:  resource record type
 *$record_class*: resource record class. Default "IN".
 *$ttl*:          Time to Live for the Resource Record. Optional.

*/
define bind::record($ensure=present,
    $zone,
    $owner=false,
    $host,
    $record_type,
    $record_class='IN',
    $ttl=false,
    $order=undef) {

    if $owner {
      $_owner = $owner
    } else {
      $_owner = $name
    }

    concat::fragment {
        "named.zone.${zone}.${record_type}.${name}":
            target  => "/etc/bind/pri/${zone}.conf",
            content => template("bind/default-record.erb"),
            order   => $order;
    }
}
