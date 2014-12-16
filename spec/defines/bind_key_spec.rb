require 'spec_helper'

describe 'bind::key' do

  let (:title) {'update.domain.tld'}

  let(:pre_condition) do
    "class { 'bind': }"
  end

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge({
          :concat_basedir => '/var/lib/puppet/concat',
        })
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
        it 'should fail' do
          expect { should contain_concat("#{confdir}/keys/update.domain.tld.conf")
          }.to raise_error(Puppet::Error, /Must pass secret to Bind::Key.*/)
        end
      end

      context 'when using a wrong ensure value' do
        let (:params) { {
          :ensure => 'running',
          :secret => 'abcdefg'
        } }

        it 'should fail' do
          expect { should contain_concat("#{confdir}/keys/update.domain.tld.conf")
          }.to raise_error(Puppet::Error, /\$ensure must be either.* got 'running'/)
        end
      end

      context 'when passing wrong type for algorithm' do
        let (:params) { {
          :secret    => 'abcdefg',
          :algorithm => ['abcde', 'fghij']
        } }

        it 'should fail' do
          expect { should contain_concat("#{confdir}/keys/update.domain.tld.conf")
          }.to raise_error(Puppet::Error, /\["abcde", "fghij"\] is not a string\..+/)
        end
      end

      context 'when passing wrong type for secret' do
        let (:params) { {
          :secret => ['abcde', 'fghij']
        } }

        it 'should fail' do
          expect { should contain_concat("#{confdir}/keys/update.domain.tld.conf")
          }.to raise_error(Puppet::Error, /\["abcde", "fghij"\] is not a string\..+/)
        end
      end

    end
  end
end
