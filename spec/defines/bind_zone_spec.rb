require 'spec_helper'

describe 'bind::zone' do
  let (:title) { 'domain.tld' }
  let (:facts) { {
    :osfamily        => 'Debian',
    :operatingsystem => 'Debian'
  } }

  context 'when using a wrong ensure value' do
    let (:params) { {
      :ensure      => 'running'
    } }

    it 'should fail' do
      expect { should contain_concat('/etc/bind/zones/domain.tld.conf') 
      }.to raise_error(Puppet::Error, /\$ensure must be either.* got 'running'/)
    end
  end

  context 'when passing wrong type for is_slave' do
    let (:params) { {
      :is_slave => 'hello'
    } }

    it 'should fail' do
      expect { should contain_concat('/etc/bind/zones/domain.tld.conf') 
      }.to raise_error(Puppet::Error, /"hello" is not a boolean\./)
    end
  end

  # Test all string parameters
  [:ensure, :zone_ttl, :zone_contact, :zone_serial, :zone_refresh,
   :zone_retry, :zone_expiracy, :zone_ns, :zone_xfers,
   :zone_masters, :zone_origin].each do |p|
    context "when passing wrong type for #{p}" do
      let (:params) { {
        p => false
      } }

      it 'should fail' do
        expect { should contain_concat('/etc/bind/zones/domain.tld.conf') 
        }.to raise_error(Puppet::Error, /false is not a string\./)
      end
    end
  end

  context 'when not a slave' do
    context 'when passing contact with spaces' do
      let (:params) { {
        :is_slave     => false,
        :zone_contact => 'it has spaces',
        :zone_ns      => 'ns.tld',
        :zone_serial  => '123456',
        :zone_ttl     => '60'
      } }

      it 'should fail' do
        expect { should contain_concat('/etc/bind/zones/domain.tld.conf') 
        }.to raise_error(Puppet::Error, /Wrong contact value for domain\.tld/)
      end
    end

    context 'when passing ns with spaces' do
      let (:params) { {
        :is_slave     => false,
        :zone_contact => 'admin@example.com',
        :zone_ns      => 'ns space tld',
        :zone_serial  => '123456',
        :zone_ttl     => '60'
      } }

      it 'should fail' do
        expect { should contain_concat('/etc/bind/zones/domain.tld.conf') 
        }.to raise_error(Puppet::Error, /Wrong ns value for domain\.tld/)
      end
    end

    context 'when passing wrong serial' do
      let (:params) { {
        :is_slave     => false,
        :zone_contact => 'admin@example.com',
        :zone_ns      => 'ns.tld',
        :zone_serial  => 'deadbeef',
        :zone_ttl     => '60'
      } }

      it 'should fail' do
        expect { should contain_concat('/etc/bind/zones/domain.tld.conf') 
        }.to raise_error(Puppet::Error, /Wrong serial value for domain\.tld/)
      end
    end

    context 'when passing wrong ttl' do
      let (:params) { {
        :is_slave     => false,
        :zone_contact => 'admin@example.com',
        :zone_ns      => 'ns.tld',
        :zone_serial  => '123456',
        :zone_ttl     => 'abc'
      } }

      it 'should fail' do
        expect { should contain_concat('/etc/bind/zones/domain.tld.conf') 
        }.to raise_error(Puppet::Error, /Wrong ttl value for domain\.tld/)
      end
    end
  end

end
