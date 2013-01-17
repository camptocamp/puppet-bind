# = Definition: bind::a
#
# Creates an IPv4 record.
#
# Arguments:
#  *$zone*:       Bind::Zone name
#  *zone_arpa*:   needed if you set $ptr to true
#  *$ptr*:        set it to true if you want the related PTR records
#                 NOTE: don't forget to create the zone!
#
#  For other arguments, please refer to bind::records !
#
define bind::a(
  $zone,
  $hash_data,
  $ensure = present,
  $zone_arpa = '',
  $ptr    = true,
  $content_template = false,
) {

  if ($ptr and $zone_arpa == '') {
    fail 'You need zone_arp if you want the PTR!'
  }

  bind::record {$name:
    ensure           => $ensure,
    zone             => $zone,
    hash_data        => $hash_data,
    record_type      => 'A',
    content_template => $content_template,
  }

  if $ptr {
    bind::record {"PTR ${name}":
      ensure           => $ensure,
      zone             => $zone_arpa,
      record_type      => 'PTR',
      ptr_zone         => $zone,
      hash_data        => $hash_data,
      content_template => $content_template,
    }
  }

}
