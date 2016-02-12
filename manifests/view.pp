define bind::view(
  $ensure  = 'present',
  $options = {
    'match-clients' => [ '"any"' ],
    'recursion'     => 'no',
  }
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

  concat {"${bind::params::views_directory}/${_name}.zones":
    ensure => $ensure,
    force  => true,
    group  => 'root',
    mode   => '0644',
    owner  => 'root',
  }

}
