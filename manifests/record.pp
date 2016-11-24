# = Definition: bind::record
#
# Helper to create any record you want (but NOT MX, please refer to Bind::Mx)
#
# Arguments:
#  *$zone*:             Bind::Zone name
#  *$record_type*:      Resource record type
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
#          ...
#        }
#  *$dynamic_zone*:      Specifies if the record is being added to a dynamic zone
#
define bind::record (
  $zone,
  $hash_data,
  $record_type,
  $ensure           = present,
  $content          = undef,
  $content_template = undef,
  $ptr_zone         = undef,
  $dynamic_zone     = false,
) {

  validate_string($ensure)
  validate_re($ensure, ['present', 'absent'],
              "\$ensure must be either 'present' or 'absent', got '${ensure}'")

  validate_string($zone)
  validate_string($record_type)
  validate_string($ptr_zone)
  validate_hash($hash_data)

  if ($content_template and $content) {
    fail '$content and $content_template are mutually exclusive'
  }

  if($content_template){
    warning '$content_template is deprecated. Please use $content parameter.'
    validate_string($content_template)
    $record_content = template($content_template)
  }elsif($content){
    $record_content = $content
  }else{
    $record_content = template('bind/default-record.erb')
  }

  if $dynamic_zone {
    $target_path = "${bind::params::dynamic_directory}/${zone}.conf"
  } else {
    $target_path = "${bind::params::pri_directory}/${zone}.conf"
  }

  concat::fragment {"${zone}.${record_type}.${name}":
    ensure  => $ensure,
    target  => $target_path,
    content => $record_content,
    order   => '10',
    notify  => Service['bind9'],
  }

}
