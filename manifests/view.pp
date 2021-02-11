# = Definition: bind::view
#
# Creates a valid Bind9 view.
#
# Arguments:
# *$view*         String. Name of view.
# *$view_append*  Array.
# *$geodns*       Boolean. Is your DNS a geo location or not? Default false
# *$arr_country*  Array.
#
define bind::view (
  $ensure         = present,
  $geodns         = false,
  $company        = false,
  $view           = 'default',
  $arr_country    = [],
  $view_append    = {},
  $options = {
    'recursion' => 'no',
  },
  $order          = 10,
) {

  validate_re($ensure, ['^present$', '^absent$'])
  validate_hash($options)

  validate_string($view)

  $_ensure = $ensure? {
    'present' => 'file',
    default   => $ensure,
  }


  if $company {
    $sanitize_name = regsubst($name, '\s', '-', 'G')
    $_name = "${sanitize_name}_${company}"
    $zone_dir = "${bind::params::pri_directory}/${company}"
    if ! defined(File[$zone_dir]) {
      file { $zone_dir:
        ensure => directory,
        owner  => bind,
        group  => bind,
        mode   => '0644',
      }
    }
  } else {
    $_name = regsubst($name, '\s', '-', 'G')
  }

  if $ensure == 'present' {
    concat {"${bind::params::views_directory}/${_name}.view":
      group => 'root',
      mode  => '0644',
      owner => 'root',
    }

    concat::fragment {"zone.view.${_name}":
      target  => "${bind::params::views_directory}/${_name}.view",
      content => template('bind/view.erb'),
      order   => $order,
      notify  => Exec['reload bind9'],
      require => Class['bind::install'],
    }

    concat::fragment {"named.local.view.${_name}":
      target  => "${bind::params::config_base_dir}/${bind::params::named_local_name}",
      content => "include \"${bind::params::views_directory}/${_name}.view\";\n",
      order   => $order,
      notify  => Exec['reload bind9'],
      require => Class['bind::install'],
    }
  }
}
