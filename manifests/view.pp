define bind::view(
  $ensure  = 'present',
  $options = {
    'recursion' => 'no',
  },
  $order  = 10,
) {

  validate_re($ensure, ['^present$', '^absent$'])
  validate_hash($options)

  $_ensure = $ensure? {
    'present' => 'file',
    default   => $ensure,
  }

  $_name = regsubst($name, '\s', '-', 'G')

  file {"${bind::params::views_directory}/${_name}.view":
    ensure  => $_ensure,
    content => template('bind/view.erb'),
    group   => 'root',
    mode    => '0644',
    owner   => 'root',
  }

  if $ensure == 'present' {
    concat {"${bind::params::views_directory}/${_name}.zones":
      group => 'root',
      mode  => '0644',
      owner => 'root',
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
