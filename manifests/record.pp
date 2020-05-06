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
#
define bind::record (
  $zone,
  $hash_data,
  $record_type,
  $ensure           = present,
  $content          = undef,
  $content_template = undef,
  $ptr_zone         = undef,
  $path             = false,
  $company          = false,
  $view             = 'default',
  $all_net          = false,
  $order            = '10',
) {

  validate_string($ensure)
  validate_re($ensure, ['present', 'absent'],
              "\$ensure must be either 'present' or 'absent', got '${ensure}'")

  validate_string($zone)
  validate_string($record_type)
  validate_string($ptr_zone)
  validate_string($content_template)
  validate_hash($hash_data)

  if $path {
    $full_zone_path = $path
  } else {
    if $record_type == 'PTR' {
      $host = keys($hash_data)[0]
      $ip = $hash_data[$host]['owner']
      $net = net_include($all_net, $ip)
      if $net {
        $rev_subnet = net_reverse($net)
        if $view == 'unset' {
          $full_zone_path = "${bind::params::pri_directory}/${company}/${rev_subnet}.in-addr.arpa.conf"
        } else {
          $full_zone_path = "${bind::params::pri_directory}/${company}/${view}/${rev_subnet}.in-addr.arpa.conf"
        }
      } else {
        $full_zone_path = false
        notice("Can't found net ${ip} in all_net ${all_net}")
      }
    } else {
      if $company {
        $full_zone_path = "${bind::params::pri_directory}/${company}/${view}/${zone}.conf"
      } else {
        $full_zone_path = "${bind::params::pri_directory}/${view}/${zone}.conf"
      }
    }
  }

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

  if $full_zone_path {
    if ! defined(Concat[$full_zone_path]) {
      concat {$full_zone_path:
        owner => root,
        group => root,
        mode  => '0644',
        force => true,
      }
    }
  }

  if $ensure == 'present' {
    if $full_zone_path {
      concat::fragment {"${view}.${zone}.${record_type}.${name}":
        target  => $full_zone_path,
        content => $record_content,
        order   => $order,
        notify  => Service['bind9'],
      }
    }
  }
}
