require 'spec_helper_acceptance'

describe 'bind' do

  context 'with defaults' do
    it 'should apply without error' do
      pp = <<-EOS
        class { 'bind': }
      EOS

      apply_manifest(pp, :catch_failures => true)
    end
    it 'should idempotently run' do
      pp = <<-EOS
        class { 'bind': }
      EOS

      apply_manifest(pp, :catch_changes => true)
    end


    it 'should create a zone and load it' do
      pp = <<-EOS
        class {'::bind': }
        ::bind::zone {'my-zone.tld':
          ensure       => present,
          zone_contact => 'contact.my-zone.tld',
          zone_ns      => [
            'ns0.my-zone.tld',
            'ns1.my-zone.tld',
          ],
          zone_serial  => '201602120937',
          zone_ttl     => '18600',
        }
        ::bind::a {'A records':
          ensure    => present,
          zone      => 'my-zone.tld',
          ptr       => false,
          hash_data => {
            '@'   => { owner => '192.168.10.1', },
            'ns0' => { owner => '192.168.10.252', },
            'ns1' => { owner => '192.168.10.253', },
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

  end
end
