require 'spec_helper'

describe 'bind::key' do
  let(:title) { 'update.domain.tld' }

  let(:pre_condition) do
    "class { 'bind': }"
  end

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(concat_basedir: '/var/lib/puppet/concat')
      end

      let(:confdir) do
        case facts[:osfamily]
        when 'Debian'
          '/etc/bind'
        when 'RedHat'
          '/etc/named'
        end
      end

      # Validate input
      context 'when missing secret value' do
        it 'fails' do
          expect {
            is_expected.to contain_concat("#{confdir}/keys/update.domain.tld.conf")
          }.to raise_error(StandardError, %r{secret})
        end
      end

      context 'when using a wrong ensure value' do
        let(:params) do
          {
            ensure: 'running',
            secret: 'abcdefg',
          }
        end

        it 'fails' do
          expect {
            is_expected.to contain_concat("#{confdir}/keys/update.domain.tld.conf")
          }.to raise_error(Puppet::Error, %r{\$ensure must be either.* got 'running'})
        end
      end

      context 'when passing wrong type for algorithm' do
        let(:params) do
          {
            secret: 'abcdefg',
            algorithm: ['abcde', 'fghij'],
          }
        end

        it 'fails' do
          expect {
            is_expected.to contain_concat("#{confdir}/keys/update.domain.tld.conf")
          }.to raise_error(Puppet::Error, %r{\["abcde", "fghij"\] is not a string\..+})
        end
      end

      context 'when passing wrong type for secret' do
        let(:params) do
          {
            secret: ['abcde', 'fghij'],
          }
        end

        it 'fails' do
          expect {
            is_expected.to contain_concat("#{confdir}/keys/update.domain.tld.conf")
          }.to raise_error(Puppet::Error, %r{\["abcde", "fghij"\] is not a string\..+})
        end
      end
    end
  end
end
