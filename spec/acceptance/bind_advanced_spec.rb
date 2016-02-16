require 'spec_helper_acceptance'

describe 'bind' do

  let(:serial) { '2016021209' }

  context "With dedicated view, acl and zone" do

    it "should create a view, attach a zone to it and load without error" do
      pp = <<-EOS
        class {'::bind':
          default_view => {
            'match-clients' => ['!127.0.0.0/8', '"any"'],
          }
        }
        ::bind::acl {'internal':
          ensure => present,
          acls   => [
            '127.0.0.0/8',
          ],
        }
        ::bind::view {'my-view':
          options => {
            'include'       => "\"${bind::params::config_base_dir}/${bind::params::default_zones_file}\"",
            'match-clients' => ['"internal"'],
          },
        }
        ::bind::zone {'my-zone.tld':
          ensure       => present,
          view         => 'my-view',
          zone_contact => 'contact.my-zone.tld',
          zone_ns      => [
            'ns0.my-zone.tld',
            'ns1.my-zone.tld',
          ],
          zone_serial  => '#{serial}',
          zone_ttl     => '18600',
        }
        ::bind::a {'A records':
          ensure    => present,
          zone      => 'my-zone.tld',
          ptr       => false,
          hash_data => {
            '@'    => { owner => '192.168.10.1', },
            'test' => { owner => '192.168.10.2', },
            'ns0'  => { owner => '192.168.10.252', },
            'ns1'  => { owner => '192.168.10.253', },
          }
        }
        case $::osfamily {
          'Debian': {
            package {'dnsutils': }
          }
          'RedHat': {
            package {'bind-utils': }
          }
        }
      EOS

      apply_manifest(pp, :cat_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe port("53") {
      it {
        should be_listening.with('tcp')
        should be_listening.with('udp')
      }
    }

    describe command("host -4 ns1.my-zone.tld localhost") do
      its(:stdout) {should match /ns1.my-zone.tld has address 192.168.10.253/}
    end
    describe command("host -4 google-public-dns-b.google.com localhost") do
      its(:stdout) {should match /google-public-dns-b.google.com has address 8.8.4.4/}
    end


  end
end
