# = Class: bind::params
# Setup parameters based on OS
# You should NOT include this class as is, as it won't work at all!
# Please refer to Class['bind'].

class bind::params {
  if $::osfamily == 'Debian' {
    $package_name         = 'bind9'
    $service_name         = 'bind9'
    $bind_user            = 'bind'
    $bind_group           = 'bind'
    $service_has_status   = true
    #$service_pattern will only be used if $service_has_status is false
    $service_pattern      = undef
    $service_restart      = '/etc/init.d/bind9 reload'
    $config_base_dir      = '/etc/bind'
    $named_conf_name      = 'named.conf'
    $named_local_name     = 'named.conf.local'
    $zones_directory      = '/etc/bind/zones'
    $pri_directory        = '/etc/bind/pri'
    $keys_directory       = '/etc/bind/keys'
    $dynamic_directory    = '/etc/bind/dynamic'
    $acls_directory       = '/etc/bind/acls'
    $views_directory      = '/etc/bind/views'
    $default_zones_file   = 'named.conf.default-zones'
    $default_config       = {
      'directory'         => '"/var/cache/bind"',
      'dnssec-validation' => 'auto',
      'auth-nxdomain'     => 'no',
      'listen-on-v6'      => ['any'],
    }
    $default_logging = {
      'channels'           => {
        'simple_log'       => {
          'file'           => '"/var/log/named/bind.log"',
          'severity'       => 'warning',
          'print-time'     => 'yes',
          'print-severity' => 'yes',
          'print-category' => 'yes',
        },
      },
      'categories'         => {
        'default'          => 'simple_log',
      },
    }
    if $bind::chroot {
      fail('Chroot mode is not yet implemented for Debian in this module.')
    }
  }
  elsif $::osfamily == 'RedHat' {
    if $bind::chroot {
      $package_name         = 'bind-chroot'
      $service_name         = 'named-chroot'
      # moving this under named so it also is available within the chroot.
      $named_local_name     = 'named/named.conf.local'
    } else {
      $package_name         = 'bind'
      $service_name         = 'named'
      $named_local_name     = 'named.conf.local'
    }
    $bind_user            = 'named'
    $bind_group           = 'named'
    $service_pattern      = undef
    if versioncmp($::operatingsystemmajrelease,'7') < 0 {
      $service_restart      = "/etc/init.d/${service_name} restart"
      $service_has_status   = false
    } else {
      $service_restart      = "/usr/bin/systemctl reload ${service_name}"
      $service_has_status   = true
    }
    $config_base_dir      = '/etc'
    $named_conf_name      = 'named.conf'
    $zones_directory      = '/etc/named/zones'
    $pri_directory        = '/etc/named/pri'
    $keys_directory       = '/etc/named/keys'
    $dynamic_directory    = '/etc/named/dynamic'
    $acls_directory       = '/etc/named/acls'
    $views_directory      = '/etc/named/views'
    $default_zones_file   = 'named.rfc1912.zones'
    $default_config       = {
      'allow-query'            => ['localhost'],
      'auth-nxdomain'          => 'no',
      'bindkeys-file'          => '"/etc/named.iscdlv.key"',
      'directory'              => '"/var/named"',
      'dnssec-enable'          => 'yes',
      'dnssec-validation'      => 'yes',
      'dump-file'              => '"/var/named/data/cache_dump.db"',
      'managed-keys-directory' => '"/var/named/dynamic"',
      'memstatistics-file'     => '"/var/named/data/named_mem_stats.txt"',
      'pid-file'               => '"/run/named/named.pid"',
      'listen-on'              => ['127.0.0.1'],
      'listen-on-v6'           => ['::1'],
      'session-keyfile'        => '"/run/named/session.key"',
      'statistics-file'        => '"/var/named/data/named_stats.txt"',
    }
    $default_logging = {
      'channels'           => {
        'simple_log'       => {
          'file'           => '"/var/log/named/bind.log"',
          'severity'       => 'warning',
          'print-time'     => 'yes',
          'print-severity' => 'yes',
          'print-category' => 'yes',
        },
      },
      'categories'         => {
        'default'          => 'simple_log',
      },
    }
  }
  elsif $::osfamily == 'Suse' {
    $package_name         = 'bind'
    $service_name         = 'named'
    $named_local_name     = 'named.conf.include'
    $bind_user            = 'named'
    $bind_group           = 'named'
    $service_pattern      = undef
    $service_restart      = "/usr/bin/systemctl reload ${service_name}"
    $service_has_status   = true
    $config_base_dir      = '/etc'
    $named_conf_name      = 'named.conf'
    $zones_directory      = '/etc/named.d/zones'
    $pri_directory        = '/etc/named.d/pri'
    $keys_directory       = '/etc/named.d/keys'
    $dynamic_directory    = '/etc/named.d/dyn'
    $acls_directory       = '/etc/named.d/acls'
    $views_directory      = '/etc/named.d/views'
    $default_zones_file   = 'named.d/default-zones'
    $default_config       = {
      'directory'              => '"/var/lib/named"',
      'managed-keys-directory' => '"/var/lib/named/dyn"',
      'dump-file'              => '"/var/log/named_dump.db"',
      'statistics-file'        => '"/var/log/named.stats"',
      'listen-on-v6'           => ['any'],
      'notify'                 => 'no',
      'disable-empty-zone'     => '"1.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.IP6.ARPA"',
    }
    $default_logging = {}
  }
  else {
    fail "Unknown ${::operatingsystem}"
  }
}
