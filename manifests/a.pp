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
  $ensure           = present,
  $zone_arpa        = undef,
  $ptr              = true,
  $content          = undef,
  $content_template = undef,
  $path             = false,
  $company          = false,
  $view             = 'default',
  $all_net          = false
) {

  validate_string($ensure)
  validate_re($ensure, ['present', 'absent'],
              "\$ensure must be either 'present' or 'absent', got '${ensure}'")

  validate_string($zone)
  validate_string($zone_arpa)
  validate_hash($hash_data)
  validate_bool($ptr)

  if ($ptr and !$zone_arpa) {
    fail 'You need zone_arpa if you want the PTR!'
  }

  if ($content and $content_template) {
    fail '$content and $content_template are mutually exclusive'
  }

  if ! $path {
    $base_path = $bind::params::pri_directory
    if $company {
      $tmp_dir = "${bind::params::pri_directory}/${company}/${view}"
    } else {
      $tmp_dir = "${bind::params::pri_directory}/${view}"
    }

    $full_path = "${tmp_dir}/${zone}.conf"
  } else {
    $full_path = $path
  }

  bind::record {$name:
    ensure           => $ensure,
    zone             => $zone,
    hash_data        => $hash_data,
    record_type      => 'A',
    content          => $content,
    content_template => $content_template,
    path             => $full_path,
    company          => $company,
    view             => $view,
  }

  if $ptr {
    bind::record {"PTR ${name}":
      ensure           => $ensure,
      zone             => $zone_arpa,
      record_type      => 'PTR',
      ptr_zone         => $zone,
      hash_data        => $hash_data,
      content          => $content,
      content_template => $content_template,
      company          => $company,
      view             => $view,
      all_net          => $all_net
    }
  }
}
