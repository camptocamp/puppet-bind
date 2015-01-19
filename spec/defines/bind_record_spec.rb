require 'spec_helper'

describe 'bind::record' do

  let (:title) { 'CNAME foo.example.com' }

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

      let :pre_condition do
        "class {'bind':}"
      end

      context 'when using a wrong ensure value' do
        let (:params) { {
          :ensure      => 'running',
          :zone        => 'foo.example.com',
          :hash_data   => {},
          :record_type => 'CNAME'
        } }

        it 'should fail' do
          expect { should contain_concat__fragment('')
          }.to raise_error(Puppet::Error, /\$ensure must be either.* got 'running'/)
        end
      end

      context 'when zone is not specified' do
        let (:params) { {
          :hash_data   => {},
          :record_type => 'CNAME'
        } }

        it 'should fail' do
          expect { should contain_concat__fragment('')
          }.to raise_error(Puppet::Error, /Must pass zone to Bind::Record/)
        end
      end

      context 'when passing wrong type for zone' do
        let (:params) { {
          :zone        => ['foo.example.com'],
          :hash_data   => {},
          :record_type => 'CNAME'
        } }

        it 'should fail' do
          expect { should contain_concat__fragment('')
          }.to raise_error(Puppet::Error, /\["foo.example.com"\] is not a string\./)
        end
      end

      context 'when hash_data is not specified' do
        let (:params) { {
          :zone        => 'foo.example.com',
          :record_type => 'CNAME'
        } }

        it 'should fail' do
          expect { should contain_concat__fragment('')
          }.to raise_error(Puppet::Error, /Must pass hash_data to Bind::Record/)
        end
      end

      context 'when passing wrong type for hash_data' do
        let (:params) { {
          :zone        => 'foo.example.com',
          :hash_data   => 'bar',
          :record_type => 'CNAME'
        } }

        it 'should fail' do
          expect { should contain_concat__fragment('')
          }.to raise_error(Puppet::Error, /"bar" is not a Hash\./)
        end
      end

      context 'when record_type is not specified' do
        let (:params) { {
          :zone        => 'foo.example.com',
          :hash_data   => {}
        } }

        it 'should fail' do
          expect { should contain_concat__fragment('')
          }.to raise_error(Puppet::Error, /Must pass record_type to Bind::Record/)
        end
      end

      context 'when passing wrong type for record_type' do
        let (:params) { {
          :zone        => 'foo.example.com',
          :hash_data   => {},
          :record_type => ['CNAME']
        } }

        it 'should fail' do
          expect { should contain_concat__fragment('')
          }.to raise_error(Puppet::Error, /\["CNAME"\] is not a string\./)
        end
      end

      context 'when passing wrong type for ptr_zone' do
        let (:params) { {
          :zone        => 'foo.example.com',
          :hash_data   => {},
          :record_type => 'CNAME',
          :ptr_zone    => ['bar']
        } }

        it 'should fail' do
          expect { should contain_concat__fragment('')
          }.to raise_error(Puppet::Error, /\["bar"\] is not a string\./)
        end
      end

      context 'when passing wrong type for content_template' do
        let (:params) { {
          :zone             => 'foo.example.com',
          :hash_data        => {},
          :record_type      => 'CNAME',
          :content_template => ['bar']
        } }

        it 'should fail' do
          expect { should contain_concat__fragment('')
          }.to raise_error(Puppet::Error, /\["bar"\] is not a string\./)
        end
      end

      context 'when using default content_template' do
        let (:params) { {
          :zone        => 'foo.example.com',
          :hash_data   => {},
          :record_type => 'CNAME'
        } }

        it {
          should contain_concat__fragment('foo.example.com.CNAME.CNAME foo.example.com')
        }
      end

      context 'when passing a wrong hostname in data' do
        let (:params) { {
          :zone      => 'foo.example.com',
          :hash_data => {
            'host 1' => {},
          },
          :record_type => 'CNAME',
        } }

        it 'should fail' do
          expect {
            should contain_concat__fragment('foo.example.com')
          }.to raise_error(Puppet::Error, /'host 1' is NOT a valid name/)
        end
      end

      context 'when passing a wrong owner in data with PTR' do
        let (:params) { {
          :zone       => 'foo.example.com',
          :hash_data  => {
            'host1'   => {
              'owner' => 'wrong value',
              'ptr'   => true,
            },
          },
          :record_type => 'PTR',
          :ptr_zone    => 'foo',
        } }

        it 'should fail' do
          expect {
            should contain_concat__fragment('')
          }.to raise_error(Puppet::Error, /invalid address/)
        end
      end

      context 'when passing data with PTR without ptr_zone' do
        let (:title) { 'PTR entry' }
        let (:params) { {
          :zone       => 'foo.example.com',
          :hash_data  => {
            'host1'   => {
              'owner' => '1.2.3.4',
              'ptr'   => true,
            },
          },
          :record_type => 'PTR',
        } }

        it 'should fail' do
          expect {
            should contain_concat__fragment('')
          }.to raise_error(Puppet::Error, /nil does not match/)
        end
      end

      context 'when passing data with PTR' do
        let (:title) { 'PTR entry' }
        let (:params) { {
          :zone       => 'foo.example.com',
          :hash_data  => {
            'host1'   => {
              'owner' => '1.2.3.4',
              'ptr'   => true,
            },
          },
          :record_type => 'PTR',
          :ptr_zone    => 'foo',
        } }

        it {
          should contain_concat__fragment('foo.example.com.PTR.PTR entry').with_content(
            /4\.3\.2\.1\.in-addr\.arpa\.  IN PTR host1\.foo\./
          ).with_content(
            /host1  IN PTR 1\.2\.3\.4/
          )
        }
      end

      context 'when passing data with PTR and ttl' do
        let (:title) { 'PTR entry' }
        let (:params) { {
          :zone       => 'foo.example.com',
          :hash_data  => {
            'host1'   => {
              'owner' => '1.2.3.4',
              'ptr'   => true,
              'ttl'   => '60',
            },
          },
          :record_type => 'PTR',
          :ptr_zone    => 'foo',
        } }

        it {
          should contain_concat__fragment('foo.example.com.PTR.PTR entry').with_content(
            /4\.3\.2\.1\.in-addr\.arpa\. 60 IN PTR host1\.foo\./
          ).with_content(
            /host1 60 IN PTR 1\.2\.3\.4/
          )
        }
      end

      context 'when passing data with PTR and host=@' do
        let (:title) { 'PTR entry' }
        let (:params) { {
          :zone       => 'foo.example.com',
          :hash_data  => {
            '@'   => {
              'owner' => '1.2.3.4',
              'ptr'   => true,
            },
          },
          :record_type => 'PTR',
          :ptr_zone    => 'foo',
        } }

        it {
          should contain_concat__fragment('foo.example.com.PTR.PTR entry').with_content('')
        }
      end

      context 'when passing data with A' do
        let (:title) { 'A entry' }
        let (:params) { {
          :zone       => 'foo.example.com',
          :hash_data  => {
            'host1'   => {
              'owner' => '1.2.3.4',
            },
          },
          :record_type => 'A',
        } }

        it {
          should contain_concat__fragment('foo.example.com.A.A entry').with_content(
            /host1  IN A 1\.2\.3\.4/
          )
        }
      end

      context 'when passing data with A with ttl' do
        let (:title) { 'A entry' }
        let (:params) { {
          :zone       => 'foo.example.com',
          :hash_data  => {
            'host1'   => {
              'owner' => '1.2.3.4',
              'ttl'   => '60',
            },
          },
          :record_type => 'A',
        } }

        it {
          should contain_concat__fragment('foo.example.com.A.A entry').with_content(
            /host1 60 IN A 1\.2\.3\.4/
          )
        }
      end

      context 'when passing SRV with _' do
        let (:title) { 'SRV entry' }
        let (:params) { {
          :zone       => 'foo.example.com',
          :hash_data  => {
            '_sip._tcp.foo.example.com.'   => {
              'owner' => '0 5 5060 sipserver.example.com.',
              'ttl'   => '86400',
            },
          },
          :record_type => 'SRV',
        } }

        it {
          should contain_concat__fragment('foo.example.com.SRV.SRV entry').with_content(
            /_sip\._tcp\.foo\.example.com. 86400 IN SRV 0 5 5060 sipserver\.example\.com\./
          )
        }
      end
    end
  end
end
