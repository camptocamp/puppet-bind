# Fake $::concat_basedir fact
$concat_basedir = '/var/lib/puppet/concat'

# Default node to test defines
node default {
  bind::zone {'test.tld':
    zone_contact => 'contact.test.tld',
    zone_ns      => 'ns0.test.tld',
    zone_serial  => '2012112901',
    zone_ttl     => '604800',
    zone_origin  => 'test.tld',
  }
}
