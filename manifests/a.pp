# = Definition: bind::a
#
# Creates an IPv4 record.
#
# Arguments:
# *$zone*:  Bind::Zone name
# *$owner*: owner of the Resource Record
# *$host*:  target of the Resource Record
# *$ttl*:   Time to Live for the Resource Record. Optional.
# *$ptr*:   create the corresponding ptr record (default=false)
#
#
define bind::a(
  $zone,
  $host,
  $ensure = present,
  $owner  = false,
  $ttl    = false,
  $ptr    = false
) {

  bind::record {$name:
    ensure      => $ensure,
    zone        => $zone,
    owner       => $owner,
    host        => $host,
    ttl         => $ttl,
    record_type => 'A',
  }

  if $ptr {
    $arpa      = inline_template("<%= require 'ipaddr'; IPAddr.new(host).reverse %>")
    $arpa_zone = inline_template("<%= require 'ipaddr'; IPAddr.new(host).reverse.split('.')[1..-1].join('.') %>")

    bind::ptr {"${arpa}.":
      ensure => $ensure,
      zone   => $arpa_zone,
      host   => $name,
      ttl    => $ttl,
    }
  }

}
