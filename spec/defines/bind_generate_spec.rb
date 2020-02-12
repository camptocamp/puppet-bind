require 'spec_helper'

describe 'bind::generate' do
  let(:title) { 'test.tld' }

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

      context 'when using a wrong ensure value' do
        let(:params) do
          {
            ensure: 'running',
            zone: 'test.tld',
            range: '2-100',
            record_type: 'A',
            lhs: 'dhcp-$',
            rhs: '10.10.0.$',
          }
        end

        it 'fails' do
          expect {
            is_expected.to contain_concat__fragment('test.tld')
          }.to raise_error(Puppet::Error, %r{\$ensure must be either.* got 'running'})
        end
      end

      context 'when zone is not specified' do
        let(:params) do
          {
            range: '2-100',
            record_type: 'A',
            lhs: 'dhcp-$',
            rhs: '10.10.0.$',
          }
        end

        it 'fails' do
          expect {
            is_expected.to contain_concat__fragment('test.tld')
          }.to raise_error(StandardError, %r{zone})
        end
      end

      context 'when passing wrong type for zone' do
        let(:params) do
          {
            zone: ['test.tld'],
            range: '2-100',
            record_type: 'A',
            lhs: 'dhcp-$',
            rhs: '10.10.0.$',
          }
        end

        it 'fails' do
          expect {
            is_expected.to contain_concat__fragment('test.tld')
          }.to raise_error(Puppet::Error, %r{\["test.tld"\] is not a string\.})
        end
      end

      context 'when range is not specified' do
        let(:params) do
          {
            zone: 'test.tld',
            record_type: 'A',
            lhs: 'dhcp-$',
            rhs: '10.10.0.$',
          }
        end

        it 'fails' do
          expect {
            is_expected.to contain_concat__fragment('test.tld')
          }.to raise_error(StandardError, %r{range})
        end
      end

      context 'when passing wrong type for range' do
        let(:params) do
          {
            zone: 'test.tld',
            range: ['2-100'],
            record_type: 'A',
            lhs: 'dhcp-$',
            rhs: '10.10.0.$',
          }
        end

        it 'fails' do
          expect {
            is_expected.to contain_concat__fragment('test.tld')
          }.to raise_error(Puppet::Error, %r{\["2-100"\] is not a string\.})
        end
      end

      context 'when record_type is not specified' do
        let(:params) do
          {
            zone: 'test.tld',
            range: '2-100',
            lhs: 'dhcp-$',
            rhs: '10.10.0.$',
          }
        end

        it 'fails' do
          expect {
            is_expected.to contain_concat__fragment('test.tld')
          }.to raise_error(StandardError, %r{record_type})
        end
      end

      context 'when passing wrong type for record_type' do
        let(:params) do
          {
            zone: 'test.tld',
            range: '2-100',
            record_type: ['A'],
            lhs: 'dhcp-$',
            rhs: '10.10.0.$',
          }
        end

        it 'fails' do
          expect {
            is_expected.to contain_concat__fragment('test.tld')
          }.to raise_error(Puppet::Error, %r{\["A"\] is not a string\.})
        end
      end

      context 'when lhs is not specified' do
        let(:params) do
          {
            zone: 'test.tld',
            range: '2-100',
            record_type: 'A',
            rhs: '10.10.0.$',
          }
        end

        it 'fails' do
          expect {
            is_expected.to contain_concat__fragment('test.tld')
          }.to raise_error(StandardError, %r{lhs})
        end
      end

      context 'when passing wrong type for lhs' do
        let(:params) do
          {
            zone: 'test.tld',
            range: '2-100',
            record_type: 'A',
            lhs: ['dhcp-$'],
            rhs: '10.10.0.$',
          }
        end

        it 'fails' do
          expect {
            is_expected.to contain_concat__fragment('test.tld')
          }.to raise_error(Puppet::Error, %r{\["dhcp-\$"\] is not a string\.})
        end
      end

      context 'when rhs is not specified' do
        let(:params) do
          {
            zone: 'test.tld',
            range: '2-100',
            record_type: 'A',
            lhs: 'dhcp-$',
          }
        end

        it 'fails' do
          expect {
            is_expected.to contain_concat__fragment('test.tld')
          }.to raise_error(StandardError, %r{rhs})
        end
      end

      context 'when passing wrong type for rhs' do
        let(:params) do
          {
            zone: 'test.tld',
            range: '2-100',
            record_type: 'A',
            lhs: 'dhcp-$',
            rhs: ['10.10.0.$'],
          }
        end

        it 'fails' do
          expect {
            is_expected.to contain_concat__fragment('test.tld')
          }.to raise_error(Puppet::Error, %r{\["10\.10\.0\.\$"\] is not a string\.})
        end
      end

      context 'when passing wrong type for record_class' do
        let(:params) do
          {
            zone: 'test.tld',
            range: '2-100',
            record_type: 'A',
            lhs: 'dhcp-$',
            rhs: '10.10.0.$',
            record_class: [],
          }
        end

        it 'fails' do
          expect {
            is_expected.to contain_concat__fragment('test.tld')
          }.to raise_error(Puppet::Error, %r{\[\] is not a string\.})
        end
      end

      context 'when passing wrong type for ttl' do
        let(:params) do
          {
            zone: 'test.tld',
            range: '2-100',
            record_type: 'A',
            lhs: 'dhcp-$',
            rhs: '10.10.0.$',
            ttl: ['60'],
          }
        end

        it 'fails' do
          expect {
            is_expected.to contain_concat__fragment('test.tld')
          }.to raise_error(Puppet::Error, %r{\["60"\] is not a string\.})
        end
      end

      context 'when using example 1' do
        let(:title) { 'a-record' }
        let(:params) do
          {
            zone: 'test.tld',
            range: '2-100',
            record_type: 'A',
            lhs: 'dhcp-$',
            rhs: '10.10.0.$',
          }
        end

        it {
          is_expected.to contain_concat__fragment('a-record.generate').with(target: "#{confdir}/pri/test.tld.conf",
                                                                            content: "\$GENERATE 2-100 dhcp-\$   A 10.10.0.\$ ; a-record\n")
        }
      end

      context 'when using example 2' do
        let(:title) { 'a-record' }
        let(:params) do
          {
            zone: 'test.tld',
            range: '2-100',
            record_type: 'CNAME',
            lhs: 'dhcp-$',
            rhs: '10.10.0.$',
          }
        end

        it {
          is_expected.to contain_concat__fragment('a-record.generate').with(target: "#{confdir}/pri/test.tld.conf",
                                                                            content: "\$GENERATE 2-100 dhcp-\$   CNAME 10.10.0.\$ ; a-record\n")
        }
      end

      context 'when using example 3' do
        let(:title) { 'ptr-record' }
        let(:params) do
          {
            zone: '0.10.10.IN-ADDR.ARPA',
            range: '2-100',
            record_type: 'PTR',
            lhs: '$.0.10.10.IN-ADDR.ARPA.',
            rhs: 'dhcp-$.test.tld.',
          }
        end

        it {
          is_expected.to contain_concat__fragment('ptr-record.generate').with(target: "#{confdir}/pri/0.10.10.IN-ADDR.ARPA.conf",
                                                                              content: "$GENERATE 2-100 $.0.10.10.IN-ADDR.ARPA.   PTR dhcp-$.test.tld. ; ptr-record\n")
        }
      end
    end
  end
end
