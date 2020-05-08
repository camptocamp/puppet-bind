require 'spec_helper_acceptance'

describe 'bind' do
  let(:serial) { '2016021209' }

  context 'with defaults' do
    it 'applies without error' do
      pp = <<-EOS
        class { 'bind': }
      EOS

      apply_manifest(pp, catch_failures: true)
    end
    it 'idempotentlies run' do
      pp = <<-EOS
        class { 'bind': }
      EOS

      apply_manifest(pp, catch_changes: true)
    end

    it 'creates a zone and load it' do
      pp = <<-EOS
        class {'::bind': }
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
            package {'iproute': }
          }
        }
      EOS

      apply_manifest(pp, cat_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe port('53') do
      it {
        is_expected.to be_listening.with('tcp')
        is_expected.to be_listening.with('udp')
      }
    end

    describe command('host -4 google-public-dns-a.google.com localhost') do
      its(:stdout) { is_expected.to match %r{not found: 5\(REFUSED\)} }
    end
    describe command('host -4 ns0.my-zone.tld localhost') do
      its(:stdout) { is_expected.to match %r{ns0.my-zone.tld has address 192.168.10.252} }
    end
  end
end
