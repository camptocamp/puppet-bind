# = Definition: bind::record
#
# Helper to create any record you want (but NOT MX, please refer to Bind::Mx)
#
# Arguments:
#  *$zone*:             Bind::Zone name
#  *$record_type°:      Resource record type
#  *$ptr_zone*:         PTR zone - optional
#  *$content_template*: Allows you to do your own template, letting you
#                       use your own hash_data content structure
#  *$hash_data:         Hash containing data, by default in this form:
#        {
#          <host>         => {
#            owner        => <owner>,
#            ttl          => <TTL> (optional),
#            record_class => <Class>, (optional - default IN)
#          },
#          <host>         => {
#            owner        => <owner>,
#            ttl          => <TTL> (optional),
#            ptr          => false, (optional, default to true)
#            record_class => <Class>, (optional - default IN)
#          },
#          …
#        }
#
define bind::record (
  $zone,
  $hash_data,
  $record_type,
  $ensure   = present,
  $ptr_zone = '',
  $content_template = false
) {
  
  $records_template = $content_template ?{
    false   => 'bind/default-record.erb',
    ''      => 'bind/default-record.erb',
    true    => 'bind/default-record.erb',
    default => $content_template,
  }

  concat::fragment {"${zone}.${record_type}.${name}":
    ensure  => $ensure,
    target  => "/etc/bind/pri/${zone}.conf",
    content => template($records_template),
    notify  => Service['bind9'],
  }

}
