require 'spec_helper'

describe 'bind::generate' do

  let (:title) { 'test.tld' }

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

      context 'when using a wrong ensure value' do
        let (:params) { {
          :ensure      => 'running',
          :zone        => 'test.tld',
          :range       => '2-100',
          :record_type => 'A',
          :lhs         => 'dhcp-$',
          :rhs         => '10.10.0.$'
        } }

        it 'should fail' do
          expect { should contain_concat__fragment('test.tld')
          }.to raise_error(Puppet::Error, /\$ensure must be either.* got 'running'/)
        end
      end

      context 'when zone is not specified' do
        let (:params) { {
          :range       => '2-100',
          :record_type => 'A',
          :lhs         => 'dhcp-$',
          :rhs         => '10.10.0.$'
        } }

        it 'should fail' do
          expect { should contain_concat__fragment('test.tld')
          }.to raise_error(Puppet::Error, /Must pass zone to Bind::Generate/)
        end
      end

      context 'when passing wrong type for zone' do
        let (:params) { {
          :zone        => ['test.tld'],
          :range       => '2-100',
          :record_type => 'A',
          :lhs         => 'dhcp-$',
          :rhs         => '10.10.0.$'
        } }

        it 'should fail' do
          expect { should contain_concat__fragment('test.tld')
          }.to raise_error(Puppet::Error, /\["test.tld"\] is not a string\./)
        end
      end

      context 'when range is not specified' do
        let (:params) { {
          :zone        => 'test.tld',
          :record_type => 'A',
          :lhs         => 'dhcp-$',
          :rhs         => '10.10.0.$'
        } }

        it 'should fail' do
          expect { should contain_concat__fragment('test.tld')
          }.to raise_error(Puppet::Error, /Must pass range to Bind::Generate/)
        end
      end

      context 'when passing wrong type for range' do
        let (:params) { {
          :zone        => 'test.tld',
          :range       => ['2-100'],
          :record_type => 'A',
          :lhs         => 'dhcp-$',
          :rhs         => '10.10.0.$'
        } }

        it 'should fail' do
          expect { should contain_concat__fragment('test.tld')
          }.to raise_error(Puppet::Error, /\["2-100"\] is not a string\./)
        end
      end

      context 'when record_type is not specified' do
        let (:params) { {
          :zone  => 'test.tld',
          :range => '2-100',
          :lhs   => 'dhcp-$',
          :rhs   => '10.10.0.$'
        } }

        it 'should fail' do
          expect { should contain_concat__fragment('test.tld')
          }.to raise_error(Puppet::Error, /Must pass record_type to Bind::Generate/)
        end
      end

      context 'when passing wrong type for record_type' do
        let (:params) { {
          :zone        => 'test.tld',
          :range       => '2-100',
          :record_type => ['A'],
          :lhs         => 'dhcp-$',
          :rhs         => '10.10.0.$'
        } }

        it 'should fail' do
          expect { should contain_concat__fragment('test.tld')
          }.to raise_error(Puppet::Error, /\["A"\] is not a string\./)
        end
      end

      context 'when lhs is not specified' do
        let (:params) { {
          :zone        => 'test.tld',
          :range       => '2-100',
          :record_type => 'A',
          :rhs         => '10.10.0.$'
        } }

        it 'should fail' do
          expect { should contain_concat__fragment('test.tld')
          }.to raise_error(Puppet::Error, /Must pass lhs to Bind::Generate/)
        end
      end

      context 'when passing wrong type for lhs' do
        let (:params) { {
          :zone        => 'test.tld',
          :range       => '2-100',
          :record_type => 'A',
          :lhs         => ['dhcp-$'],
          :rhs         => '10.10.0.$'
        } }

        it 'should fail' do
          expect { should contain_concat__fragment('test.tld')
          }.to raise_error(Puppet::Error, /\["dhcp-\$"\] is not a string\./)
        end
      end

      context 'when rhs is not specified' do
        let (:params) { {
          :zone        => 'test.tld',
          :range       => '2-100',
          :record_type => 'A',
          :lhs         => 'dhcp-$'
        } }

        it 'should fail' do
          expect { should contain_concat__fragment('test.tld')
          }.to raise_error(Puppet::Error, /Must pass rhs to Bind::Generate/)
        end
      end

      context 'when passing wrong type for rhs' do
        let (:params) { {
          :zone        => 'test.tld',
          :range       => '2-100',
          :record_type => 'A',
          :lhs         => 'dhcp-$',
          :rhs         => ['10.10.0.$']
        } }

        it 'should fail' do
          expect { should contain_concat__fragment('test.tld')
          }.to raise_error(Puppet::Error, /\["10\.10\.0\.\$"\] is not a string\./)
        end
      end

      context 'when passing wrong type for record_class' do
        let (:params) { {
          :zone         => 'test.tld',
          :range        => '2-100',
          :record_type  => 'A',
          :lhs          => 'dhcp-$',
          :rhs          => '10.10.0.$',
          :record_class => []
        } }

        it 'should fail' do
          expect { should contain_concat__fragment('test.tld')
          }.to raise_error(Puppet::Error, /\[\] is not a string\./)
        end
      end

      context 'when passing wrong type for ttl' do
        let (:params) { {
          :zone        => 'test.tld',
          :range       => '2-100',
          :record_type => 'A',
          :lhs         => 'dhcp-$',
          :rhs         => '10.10.0.$',
          :ttl         => ['60']
        } }

        it 'should fail' do
          expect { should contain_concat__fragment('test.tld')
          }.to raise_error(Puppet::Error, /\["60"\] is not a string\./)
        end
      end

      context 'when using example 1' do
        let (:title) { 'a-record' }
        let (:params) { {
          :zone        => 'test.tld',
          :range       => '2-100',
          :record_type => 'A',
          :lhs         => 'dhcp-$',
          :rhs         => '10.10.0.$',
        } }
        it { should contain_concat__fragment('test.tld.A.2-100.generate').with({
          :ensure  => 'present',
          :target  => "#{confdir}/pri/test.tld.conf",
          :content => "\$GENERATE 2-100 dhcp-\$   A 10.10.0.\$ ; a-record\n"
        }) }
      end

      context 'when using example 2' do
        let (:title) { 'a-record' }
        let (:params) { {
          :zone        => 'test.tld',
          :range       => '2-100',
          :record_type => 'CNAME',
          :lhs         => 'dhcp-$',
          :rhs         => '10.10.0.$',
        } }
        it { should contain_concat__fragment('test.tld.CNAME.2-100.generate').with({
          :ensure  => 'present',
          :target  => "#{confdir}/pri/test.tld.conf",
          :content => "\$GENERATE 2-100 dhcp-\$   CNAME 10.10.0.\$ ; a-record\n"
        }) }
      end

      context 'when using example 3' do
        let (:title) { 'ptr-record' }
        let (:params) { {
          :zone        => '0.10.10.IN-ADDR.ARPA',
          :range       => '2-100',
          :record_type => 'PTR',
          :lhs         => '$.0.10.10.IN-ADDR.ARPA.',
          :rhs         => 'dhcp-$.test.tld.',
        } }
        it { should contain_concat__fragment('0.10.10.IN-ADDR.ARPA.PTR.2-100.generate').with({
          :ensure  => 'present',
          :target  => "#{confdir}/pri/0.10.10.IN-ADDR.ARPA.conf",
          :content => "$GENERATE 2-100 $.0.10.10.IN-ADDR.ARPA.   PTR dhcp-$.test.tld. ; ptr-record\n"
        }) }
      end
    end
  end
end
