# Bind module for Puppet

[![Puppet Forge](http://img.shields.io/puppetforge/v/camptocamp/bind.svg)](https://forge.puppetlabs.com/camptocamp/bind)
[![Build Status](https://travis-ci.org/camptocamp/puppet-bind.png?branch=master)](https://travis-ci.org/camptocamp/puppet-bind)

**Manages bind configuration under Debian / Ubuntu and CentOS.**

This module is provided by [Camptocamp](http://www.camptocamp.com/)

## Exec paths

In order to not have any path problem, you should add the following line in
some globally included .pp file:

    Exec {
      path => '/some/relevant/path:/some/other:...',
    }

For example:

    Exec {
      path => '/bin:/sbin:/usr/sbin:/usr/bin',
    }


## Classes

* bind

### bind

This class must be declared before using the definitions in this module.

## Definitions

* bind::a
* bind::generate
* bind::mx
* bind::record
* bind::zone

### bind::a

Creates an A record (or a series thereof).

    bind::a { 'Hosts in example.com':
      ensure    => 'present',
      zone      => 'example.com',
      ptr       => false,
      hash_data => {
        'host1' => { owner => '192.168.0.1', },
        'host2' => { owner => '192.168.0.2', },
      },
    }

##### `$ensure = present`
Ensure the A record is present.
##### `$zone`
Zone name.
##### `$hash_data`
Zone data.
##### `$ptr = true`
Pointer records (PTR) are used to map a network interface to a host name. Primarily used for reverse DNS.
##### `$zone_arpa = undef`
Needed if `$ptr` is true. For reverse DNS you will have to setup your reverse DNS domain. This is a special domain that ends with `in-addr.arpa`.
##### `$content = undef`
Zone content;
##### `$content_template = undef`
Zone content template.

### bind::generate

Creates a $GENERATE directive for a specific zone

    bind::generate {'a-records':
      zone        => 'test.tld',
      range       => '2-100',
      record_type => 'A',
      lhs         => 'dhcp-$', # creates dhcp-2.test.tld, dhcp-3.test.tld …
      rhs         => '10.10.0.$', # creates IP 10.10.0.2, 10.10.0.3 …
    }

##### `$ensure = present`
Ensure the generate is present.
##### `$zone`
Zone name. Must reflect a bind::zone resource.
##### `$range`
Range allocated to internal generate directive. Must be in the form 'first-last'.
##### `$record_type`
Record type. Must be one of PTR, CNAME, DNAME, A, AAAA and NS.
##### `$lhs`
Generated name.
##### `$rhs`
Record target.
##### `$record_class = undef`
Record class. Not compatible with pre-9.3 bind versions.
##### `$ttl = undef`
Time to live for generated records.

### bind::mx

Creates an MX record.

    bind::mx {'mx1':
      zone     => 'domain.ltd',
      owner    => '@',
      priority => 1,
      host     => 'mail.domain.ltd',
    }

##### `$ensure = present`
Ensure the MX record is present.
##### `$zone`
Zone name.
##### `$host`
Target of the resource record.
##### `$priority`
MX record priority.
##### `$owner = undef`
Owner of the resource record.
##### `$ttl = undef`
Time to live for the resource record.

### bind::record

Creates a generic record (or a series thereof).

    bind::record {'CNAME foo.example.com':
      zone        => 'foo.example.com',
      record_type => 'CNAME',
      hash_data   => {
        'ldap'      => { owner => 'ldap.internal', },
        'voip'      => { owner => 'voip.internal', },
      }
    }

##### `$ensure = present`
Ensure the record is present.
##### `$zone`
Zone name.
##### `$hash_data`
Hash containing data.
##### `$record_type`
Resource record type.
##### `$content = undef`
Record content.
##### `$content_template = undef`
Allows you to do your own template, letting you use your own hash_data content structure.
##### `$ptr_zone = undef`
PTR zone.

### bind::zone

Creates a zone.

    bind::zone {'test.tld':
      zone_contact => 'contact.test.tld',
      zone_ns      => ['ns0.test.tld'],
      zone_serial  => '2012112901',
      zone_ttl     => '604800',
      zone_origin  => 'test.tld',
    }

##### `$ensure = present`
Ensure the zone is present.
##### `$is_dynamic = false`
Boolean to set if a zone is dynamic.
##### `$allow_update = []`
List of hosts that are allowed to submit dynamic updates for master zones.
##### `$transfer_source = undef`
Source IP to bind to when requesting a transfer (slave only).
##### `$zone_type = master`
Specify if the zone is master/slave/forward.
##### `$zone_ttl = undef`
Time to live for your zonefile (master only).
##### `$zone_contact = undef`
Valid contact record (master only).
##### `$zone_serial = undef`
Zone serial (master only).
##### `$zone_refresh = 3h`
Time between each slave refresh (master only).
##### `$zone_retry = 1h`
Time between each slave retry (master only).
##### `$zone_expirancy = 1w`
Slave expiracy time (master only).
##### `$zone_ns = []`
Valid NS for this zone (master only).
##### `$zone_xfers = undef`
Valid xfers for zone (master only).
##### `$zone_masters = undef`
Valid master for this zone (slave only).
##### `$zone_forwarders = undef`
Valid forwarders for this zone (forward only).
##### `$zone_origin = undef`
The origin of the zone.
##### `$zone_notify = undef`
IPs to use for also-notify entry.
##### `$if_slave = false`
Boolean to set if a zone is slave.

### bind::key 

Creates a key for dynamic zones.
The 'secret' value is the key generated by dnssec-keygen.

    bind::key { 'key_dyn.test.tld':
        ensure => present,
        secret => 'xUjDQqpBHao/o7mR2dza2/Tv2DQVo9pEuMfMwhdfzeaEFZAvwA='
    }

    bind::zone {'dyn.test.tld':
      zone_contact => 'contact.test.tld',
      zone_ns      => ['ns0.test.tld'],
      zone_serial  => '2012112901',
      zone_ttl     => '604800',
      zone_origin  => 'dyn.test.tld',
      is_dynamic   => true,
      allow_update => ['key_dyn.test.tld']
    }

##### `$ensure = present`
Ensure the key is present.
##### `$secret`
Key content.
##### `$algorithm = hmac-md5`
Key algorithm.

## Contributing

Please report bugs and feature request using [GitHub issue
tracker](https://github.com/camptocamp/puppet-bind/issues).

For pull requests, it is very much appreciated to check your Puppet manifest
with [puppet-lint](https://github.com/camptocamp/puppet-bind/issues) to follow the recommended Puppet style guidelines from the
[Puppet Labs style guide](http://docs.puppetlabs.com/guides/style_guide.html).

## License

Copyright (c) 2013 <mailto:puppet@camptocamp.com> All rights reserved.

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.


