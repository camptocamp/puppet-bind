require 'spec_helper_acceptance'

describe 'bind' do

  let(:serial) { '2016021209' }

  context "With a call to bind::include" do

    it "should run and start bind" do
      pp = <<-EOS
        class {'::bind':
        }
        ::bind::zone {'my-zone.tld':
          ensure       => present,
          zone_contact => 'contact.my-zone.tld',
          zone_ns      => [
            'ns0.my-zone.tld',
            'ns1.my-zone.tld',
          ],
          zone_serial  => '#{serial}',
          zone_ttl     => '18600',
        }
        file {'/tmp/bind-include.inc':
          ensure  => file,
          content => 'include IN CNAME ns0',
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
        ::bind::include {'empty include':
          ensure => present,
          file   => '/tmp/bind-include.inc',
          zone   => 'my-zone.tld',
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
    describe command("host -4 include.my-zone.tld localhost") do
      its(:stdout) {should match /include.my-zone.tld is an alias for ns0.my-zone.tld./}
    end


  end
end
