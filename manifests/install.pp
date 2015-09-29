class bind::install {
  include ::bind::params
  package { 'bind9':
    ensure => present,
    name   => $bind::params::package_name,
  }
}
