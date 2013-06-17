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

  bind::zone {'0.10.10.IN-ADDR.ARPA':
    zone_contact => 'contact.test.tld',
    zone_ns      => 'ns0.test.tld',
    zone_serial  => '2012112901',
    zone_ttl     => '604800',
    zone_origin  => '0.10.10.IN-ADDR.ARPA',
  }
}

node dynamic_bind_zone {

  bind::zone {'test.tld':
    zone_contact => 'contact.test.tld',
    zone_ns      => 'ns0.test.tld',
    zone_serial  => '2012112901',
    zone_ttl     => '604800',
    zone_origin  => 'test.tld',
    is_dynamic   => true,
    allow_update => ['update.dynamic'],
  }

  bind::key {'update.dynamic':
    secret => 'abcdfeghij',
  }
}
