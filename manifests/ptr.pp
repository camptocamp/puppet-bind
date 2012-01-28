/*

= Definition: bind::ptr
Creates an PTR record.

Arguments:
 *$zone*:  Bind::Zone name
 *$owner*: owner of the Resource Record
 *$host*:  target of the Resource Record
 *$ttl*:   Time to Live for the Resource Record. Optional.

*/
define bind::ptr($ensure=present,
    $zone,
    $view="default",
    $owner=false,
    $host,
    $ttl=false) {

    bind::record {
        $name:
            ensure      => $ensure,
            zone        => $zone,
            view        => $view,
            owner       => $owner,
            host        => $host,
            ttl         => $ttl,
            record_type => 'PTR',
    }
}
