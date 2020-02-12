require 'spec_helper_acceptance'

describe 'bind' do
  let(:serial) { '2016021209' }

  context 'with defaults' do
    it 'applies without error' do
      pp = <<-EOS
        class { 'bind':
          config => {
            'allow-query'       => [
              'any',
            ],
            'allow-query-cache' => [
              '127.0.0.0/8',
              '::1',
            ],
            'allow-recursion'   => [
              'any',
            ],
            'forward'           => 'first',
            'forwarders'        => [
              '8.8.8.8',
              '8.8.4.4',
            ],
            'listen-on'         => [
              'any',
            ],
            'listen-on-v6'      => [
              'any',
            ],
            'max-cache-ttl'     => '300',
            'max-ncache-ttl'    => '300',
          },
          default_view          => {
            'recursion'         => 'yes',
          },
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

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe command('host -4 google-public-dns-a.google.com localhost') do
      its(:stdout) { is_expected.to match %r{google-public-dns-a.google.com has address 8.8.8.8} }
    end
    describe command('host -4 www.camptocamp.com localhost') do
      its(:stdout) { is_expected.to match %r{has address} }
    end
  end
end
