class bind::service {
  include ::bind::params

  service { 'bind9':
    ensure    => running,
    name      => $bind::params::service_name,
    enable    => true,
    restart   => $bind::params::service_restart,
    hasstatus => $bind::params::service_has_status,
    pattern   => $bind::params::service_pattern,
  }
}
