# = Definition: bind::key
#
# Helper to manage dns keys (NOT dnssec)
# used mainly for nsupdate (dynamic updates)
#
# Arguments:
#   *$secret*: key content
#   *$algorithm*: key algorithm. Default hmac-md5
#
# This definition does NOT generate the key, please refer
# to Bind9 documentation regarding dynamic update setup and
# key pair generation.
#
define bind::key(
  $secret,
  $ensure    = present,
  $algorithm = 'hmac-md5',
) {

  include ::bind::params

  validate_string($ensure)
  validate_re($ensure, ['present', 'absent'],
              "\$ensure must be either 'present' or 'absent', got '${ensure}'")

  validate_string($algorithm)
  validate_string($secret)


  file {"${bind::params::keys_directory}/${name}.conf":
    ensure  => $ensure,
    mode    => '0600',
    owner   => $bind::params::bind_user,
    group   => $bind::params::bind_group,
    content => template("${module_name}/dnskey.conf.erb"),
  }

  concat::fragment {"dnskey.${name}":
    ensure  => $ensure,
    target  => "${bind::params::config_base_dir}/${bind::params::named_local_name}",
    content => "include \"${bind::params::keys_directory}/${name}.conf\";\n",
    notify  => Exec['reload bind9'],
    require => Package['bind9'],
  }

}
