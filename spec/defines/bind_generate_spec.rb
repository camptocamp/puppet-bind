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
        when 'Suse'
          '/etc/named.d'
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
          }.to raise_error(StandardError, /zone/)
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
          }.to raise_error(StandardError, /range/)
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
          }.to raise_error(StandardError, /record_type/)
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
          }.to raise_error(StandardError, /lhs/)
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
          }.to raise_error(StandardError, /rhs/)
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
        it { should contain_concat__fragment('a-record.generate').with({
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
        it { should contain_concat__fragment('a-record.generate').with({
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
        it { should contain_concat__fragment('ptr-record.generate').with({
          :target  => "#{confdir}/pri/0.10.10.IN-ADDR.ARPA.conf",
          :content => "$GENERATE 2-100 $.0.10.10.IN-ADDR.ARPA.   PTR dhcp-$.test.tld. ; ptr-record\n"
        }) }
      end
    end
  end
end
