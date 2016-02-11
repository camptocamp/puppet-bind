class bind::config {
  include ::bind::params

  concat {"${bind::params::config_base_dir}/${bind::params::named_local_name}":
    owner => root,
    group => root,
    mode  => '0644',
    force => true,
  }

  concat {"${bind::params::config_base_dir}/acls.conf":
    force => true,
    group => 'root',
    mode  => '0644',
    owner => 'root',
  }

  file_line {'include local':
    ensure => present,
    line   => "include \"${bind::params::config_base_dir}/${bind::params::named_local_name}\";",
    path   => "${bind::params::config_base_dir}/${bind::params::named_conf_name}",
    notify => Exec['reload bind9'],
  }

  file_line {'include acls':
    ensure => present,
    line   => "include \"${bind::params::config_base_dir}/acls.conf\";",
    path   => "${bind::params::config_base_dir}/${bind::params::named_conf_name}",
    notify => Exec['reload bind9'],
  }

  file {$bind::params::zones_directory:
    ensure  => directory,
    owner   => root,
    group   => root,
    mode    => '0755',
    purge   => true,
    force   => true,
    recurse => true,
  }

  file {$bind::params::pri_directory:
    ensure  => directory,
    owner   => root,
    group   => root,
    mode    => '0755',
    purge   => true,
    force   => true,
    recurse => true,
  }

  file {$bind::params::keys_directory:
    ensure  => directory,
    owner   => root,
    group   => $bind::params::bind_group,
    mode    => '0750',
    purge   => true,
    force   => true,
    recurse => true,
  }

  file {$bind::params::acls_directory:
    ensure  => directory,
    owner   => root,
    group   => $bind::params::bind_group,
    mode    => '0750',
    purge   => true,
    force   => true,
    recurse => true,
  }

  file {$bind::params::dynamic_directory:
    ensure => directory,
    owner  => root,
    group  => $bind::params::bind_group,
    mode   => '0775',
  }

}
