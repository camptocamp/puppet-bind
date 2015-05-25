# = definition: bind::generate
#
# Creates a $GENERATE directive for a specific zone
#
# == Arguments
#  $zone:         mandatory - zone name. Must reflect a bind::zone resource
#  $range:        mandatory - range allocated to internal generate directive.
#                 Must be in the form 'first-last', like '2-254'
#  $record_type:  mandatory - must be one of PTR, CNAME, DNAME, A, AAAA and NS
#  $lhs:          mandatory - generated name (see examples)
#  $rhs:          mandatory - record target (see examples)
#  $record_class: optional - incompatible with pre-9.3 bind versions
#  $ttl:          optional - time tolive for generated records
#
# == Examples
#
# bind::zone {'test.tld':
#   zone_contact => 'contact.test.tld',
#   zone_ns      => 'ns0.test.tld',
#   zone_serial  => '2012112901',
#   zone_ttl     => '604800',
#   zone_origin  => 'test.tld',
# }
# ## Generate A records
# bind::generate {'a-records':
#   zone        => 'test.tld',
#   range       => '2-100',
#   record_type => 'A',
#   lhs         => 'dhcp-$', # creates dhcp-2.test.tld, dhcp-3.test.tld ...
#   rhs         => '10.10.0.$', # creates IP 10.10.0.2, 10.10.0.3 ...
# }
# ## Means: dig dhcp-10.test.tld will resolv to 10.10.0.10
#
# ## Generate CNAME records
# bind::generate {'a-records':
#   zone        => 'test.tld',
#   range       => '2-100',
#   record_type => 'CNAME',
#   lhs         => 'dhcp-$', # creates dhcp-2.test.tld, dhcp-3.test.tld ...
#   rhs         => 'dhcp$',  # creates IP dhcp2.test.tld, dhcp3.test.tld ...
# }
# ## Means: dig dhcp10.test.tld => dhcp-10.test.tld => 10.10.0.10
#
# bind::zone {'0.10.10.IN-ADDR.ARPA':
#   zone_contact => 'contact.test.tld',
#   zone_ns      => 'ns0.test.tld',
#   zone_serial  => '2012112901',
#   zone_ttl     => '604800',
#   zone_origin  => '0.10.10.IN-ADDR.ARPA',
# }
# ## Generates PTR
# bind::generate {'ptr-records':
#   zone        => '0.10.10.IN-ADDR.ARPA',
#   range       => '2-100',
#   record_type => 'PTR',
#   lhs         => '$.0.10.10.IN-ADDR.ARPA.', # 2.0.10.10.IN-ADDR.ARPA ...
#   rhs         => 'dhcp-$.test.tld.', # creates dhcp-2.test.tld ...
# }
# ## Means: dig 10.10.0.10 will resolv to dhcp-10.test.tld
#
#
# For more information regarding this directive
# and the definition arguments, please have a
# look at
# http://www.bind9.net/manual/bind/9.3.2/Bv9ARM.ch06.html#id2566761
#
# NOTE: in order to prevent some funky-funny thing, the orignal
# "class" and "type" variables
# are renamed as $record_class and $record_type in this definition.
#
define bind::generate(
  $zone,
  $range,
  $record_type,
  $lhs,
  $rhs,
  $ensure       = present,
  $record_class = undef,
  $ttl          = undef,
) {

  include ::bind::params

  validate_string($ensure)
  validate_re($ensure, ['present', 'absent'],
              "\$ensure must be either 'present' or 'absent', got '${ensure}'")

  validate_string($zone)
  validate_string($range)
  validate_string($record_type)
  validate_string($lhs)
  validate_string($rhs)
  validate_string($record_class)
  validate_string($ttl)

  ::concat::fragment {"${zone}.${record_type}.${range}.generate":
    ensure  => $ensure,
    target  => "${bind::params::pri_directory}/${zone}.conf",
    content => template('bind/generate.erb'),
    notify  => Service['bind9'],
  }
}
