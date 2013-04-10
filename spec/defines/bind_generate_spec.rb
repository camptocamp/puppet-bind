require 'spec_helper'

describe 'bind::generate' do
  let (:title) { 'test.tld' }
  let (:facts) { {
    :osfamily        => 'Debian',
    :operatingsystem => 'Debian'
  } }

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
end
