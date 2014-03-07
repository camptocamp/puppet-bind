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
    }
    elsif $::osfamily == 'RedHat' {
        $package_name         = 'bind'
        $service_name         = 'named'
        $bind_user            = 'named'
        $bind_group           = 'named'
        $service_has_status   = true
        $service_pattern      = undef
        $service_restart      = '/etc/init.d/named reload'
        $config_base_dir      = '/etc'
        $named_conf_name      = 'named.conf'
        $named_local_name     = 'named.conf.local'
        $zones_directory      = '/etc/named/zones'
        $pri_directory        = '/etc/named/pri'
        $keys_directory       = '/etc/named/keys'
        $dynamic_directory    = '/etc/named/dynamic'
    }
    else {
        fail "Unknown ${::operatingsystem}"
    }
}
