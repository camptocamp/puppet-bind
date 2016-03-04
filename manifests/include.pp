define bind::include (
  $zone,
  $ensure        = present,
  $file          = '',
  $inline_origin = true,
  $order         = 10,
  $origin        = '',
){

  validate_string($zone)
  validate_re($ensure, ['present', 'absent'])
  validate_string($file)
  validate_bool($inline_origin)
  validate_string($origin)

  if ($file != '') {
    $_file = $file
  } else {
    $_file = $name
  }

  concat::fragment {"${zone}.include.${name}":
    ensure  => $ensure,
    content => template('bind/include.erb'),
    notify  => Service['bind9'],
    order   => $order,
    require => File[$_file],
    target  => "${bind::params::pri_directory}/${zone}.conf",
  }
}
