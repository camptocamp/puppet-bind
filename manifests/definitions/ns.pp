/*

= Definition: bind::ns
Creates an NS record.

Arguments:
 *$zone*:  Bind::Zone name
 *$owner*: owner of the Resource Record
 *$host*:  target of the Resource Record
 *$ttl*:   Time to Live for the Resource Record. Optional.

*/
define bind::ns($ensure=present,
    $zone,
    $view="default",
    $owner=false,
    $host,
    $ttl=false) {

    bind::record {
        "$name":
            ensure      => $ensure,
            zone        => $zone,
            view        => $view,
            owner       => $owner,
            host        => $host,
            ttl         => $ttl,
            order       => 04,
            record_type => 'NS',
    }
}
