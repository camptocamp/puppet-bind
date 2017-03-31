# = Class: bind
# Include this class to install bind9 server on your node.
#
# Bind documentation:
# http://www.bind9.net/manuals
#
# Limitations:
# This modules is valid for Bind 9.7.1 (squeeze version).
# For 9.7.2, it will be really limited (no view nor ACL support).
#
# = Parameters
#
# $chroot:: If the chroot version of bind should be used. Default: false
#
#
# Example:
#
# node 'ns1.domain.ltd' {
#
#   include bind
#
#   bind::zone {'domain.ltd':
#     ensure       => present,
#     zone_contact => "contact.domain.ltd",
#     zone_ns      => $fqdn,
#     zone_serial  => '2010110804',
#     zone_ttl     => '604800',
#   }
#
#   bind::a {"ns $fqdn":
#     zone  => 'domain.ltd',
#     owner => "${fqdn}.",
#     host  => $ipaddress,
#   }
#
#   bind::a {'mail.domain.ltd':
#     zone  => 'domain.ltd',
#     owner => 'mail',
#     host  => '6.6.6.6',
#   }
#
#   bind::mx {'mx1':
#     zone     => 'domain.ltd',
#     owner    => '@',
#     priority => 1,
#     host     => 'mail.domain.ltd',
#   }
# }
#
class bind(
  $chroot       = false,
  $default_view = {},
  $config       = {},
  $logging      = {},
) {
  anchor { 'bind::begin': }
  -> class { '::bind::install': }
  -> class { '::bind::config': }
  ~> class { '::bind::service': }
  -> anchor { 'bind::end': }

  exec {'reload bind9':
    command     => $bind::params::service_restart,
    onlyif      => "named-checkconf -jz ${bind::params::config_base_dir}/${bind::params::named_conf_name}",
    refreshonly => true,
    path        => $::path,
    require     => Class['bind::service'],
  }
}
