require 'spec_helper'

describe 'bind::a' do
  let(:title) { 'foo.example.com' }

  let(:pre_condition) do
    "class { 'bind': }"
  end

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(concat_basedir: '/var/lib/puppet/concat')
      end

      context 'when using a wrong ensure value' do
        let(:params) do
          {
            ensure: 'running',
            zone: 'foo.example.com',
            hash_data: {},
          }
        end

        it 'fails' do
          expect {
            is_expected.to contain_bind__record('foo.example.com')
          }.to raise_error(Puppet::Error, %r{\$ensure must be either.* got 'running'})
        end
      end

      context 'when zone is not specified' do
        let(:params) do
          {
            hash_data: {},
          }
        end

        it 'fails' do
          expect {
            is_expected.to contain_bind__record('foo.example.com')
          }.to raise_error(StandardError, %r{zone})
        end
      end

      context 'when passing wrong type for zone' do
        let(:params) do
          {
            zone: ['foo.example.com'],
            hash_data: {},
          }
        end

        it 'fails' do
          expect {
            is_expected.to contain_bind__record('foo.example.com')
          }.to raise_error(Puppet::Error, %r{\["foo.example.com"\] is not a string\.})
        end
      end

      context 'when hash_data is not specified' do
        let(:params) do
          {
            zone: 'foo.example.com',
          }
        end

        it 'fails' do
          expect {
            is_expected.to contain_bind__record('foo.example.com')
          }.to raise_error(StandardError, %r{hash_data})
        end
      end

      context 'when passing wrong type for hash_data' do
        let(:params) do
          {
            zone: 'foo.example.com',
            hash_data: 'bar',
          }
        end

        it 'fails' do
          expect {
            is_expected.to contain_bind__record('foo.example.com')
          }.to raise_error(Puppet::Error, %r{"bar" is not a Hash\.})
        end
      end

      context 'when passing wrong type for zone_arpa' do
        let(:params) do
          {
            zone: 'foo.example.com',
            hash_data: {},
            zone_arpa: ['bar'],
          }
        end

        it 'fails' do
          expect {
            is_expected.to contain_bind__record('foo.example.com')
          }.to raise_error(Puppet::Error, %r{\["bar"\] is not a string\.})
        end
      end

      context 'when passing wrong type for ptr' do
        let(:params) do
          {
            zone: 'foo.example.com',
            hash_data: {},
            ptr: 'false',
          }
        end

        it 'fails' do
          expect {
            is_expected.to contain_bind__record('foo.example.com')
          }.to raise_error(Puppet::Error, %r{"false" is not a boolean\.})
        end
      end

      context 'when passing ptr without zone_arpa' do
        let(:params) do
          {
            zone: 'foo.example.com',
            hash_data: {},
            ptr: true,
          }
        end

        it 'fails' do
          expect {
            is_expected.to contain_bind__record('foo.example.com')
          }.to raise_error(Puppet::Error, %r{You need zone_arpa if you want the PTR})
        end
      end

      context 'when using not using ptr' do
        let(:params) do
          {
            zone: 'foo.example.com',
            hash_data: {},
            ptr: false,
          }
        end

        it {
          is_expected.to contain_bind__record('foo.example.com').with(ensure: 'present',
                                                                      zone: 'foo.example.com',
                                                                      record_type: 'A',
                                                                      hash_data: {})
        }
      end

      context 'when using using ptr' do
        let(:params) do
          {
            zone: 'foo.example.com',
            hash_data: {},
            ptr: true,
            zone_arpa: 'foobar.arpa',
          }
        end

        it {
          is_expected.to contain_bind__record('foo.example.com').with(ensure: 'present',
                                                                      zone: 'foo.example.com',
                                                                      record_type: 'A',
                                                                      hash_data: {})
        }

        it {
          is_expected.to contain_bind__record('PTR foo.example.com').with(ensure: 'present',
                                                                          zone: 'foobar.arpa',
                                                                          record_type: 'PTR',
                                                                          ptr_zone: 'foo.example.com',
                                                                          hash_data: {})
        }
      end

      context 'when using content' do
        let(:params) do
          {
            zone: 'foo.example.com',
            hash_data: {},
            ptr: false,
            content: 'abcde',
          }
        end

        it {
          is_expected.to contain_bind__record('foo.example.com').with(ensure: 'present',
                                                                      zone: 'foo.example.com',
                                                                      record_type: 'A',
                                                                      hash_data: {},
                                                                      content: 'abcde')
        }
      end

      context 'when using star catchall' do
        let(:params) do
          {
            zone: 'foo.example.com',
            hash_data: { '*' => { 'owner' => 'foo.example.com' } },
            ptr: false,
          }
        end

        it {
          is_expected.to contain_bind__record('foo.example.com').with(ensure: 'present',
                                                                      zone: 'foo.example.com',
                                                                      record_type: 'A',
                                                                      hash_data: { '*' => { 'owner' => 'foo.example.com' } })
        }
      end

      context 'when using blank host' do
        let(:params) do
          {
            zone: 'foo.example.com',
            hash_data: { '' => { 'owner' => 'foo.example.com' } },
            ptr: false,
          }
        end

        it {
          is_expected.to contain_bind__record('foo.example.com').with(ensure: 'present',
                                                                      zone: 'foo.example.com',
                                                                      record_type: 'A',
                                                                      hash_data: { '' => { 'owner' => 'foo.example.com' } })
        }
      end

      context 'when passing syntactically incorrect domain name' do
        let(:params) do
          {
            zone: 'foo.example.com',
            hash_data: { 'foo).bar' => { 'owner' => 'foo.example.com' } },
            ptr: false,
          }
        end

        it 'fails' do
          expect {
            is_expected.to contain_bind__record('foo.example.com')
          }.to raise_error(Puppet::Error, %r{'foo\)\.bar' is NOT a valid name})
        end
      end
    end
  end
end
