require 'spec_helper'

describe 'bind::a' do
  let (:title) { 'foo.example.com' }
  let (:facts) { {
    :osfamily        => 'Debian',
    :operatingsystem => 'Debian'
  } }

  context 'when using a wrong ensure value' do
    let (:params) { {
      :ensure      => 'running',
      :zone        => 'foo.example.com',
      :hash_data   => {},
    } }

    it 'should fail' do
      expect { should contain_bind__record('foo.example.com') 
      }.to raise_error(Puppet::Error, /\$ensure must be either.* got 'running'/)
    end
  end

  context 'when zone is not specified' do
    let (:params) { {
      :hash_data   => {},
    } }

    it 'should fail' do
      expect { should contain_bind__record('foo.example.com') 
      }.to raise_error(Puppet::Error, /Must pass zone to Bind::A/)
    end
  end

  context 'when hash_data is not specified' do
    let (:params) { {
      :zone        => 'foo.example.com',
    } }

    it 'should fail' do
      expect { should contain_bind__record('foo.example.com') 
      }.to raise_error(Puppet::Error, /Must pass hash_data to Bind::A/)
    end
  end

  context 'when passing ptr without zone_arpa' do
    let (:params) { {
      :zone      => 'foo.example.com',
      :hash_data => {},
      :ptr       => true,
      :zone_arpa => ''
    } }

    it 'should fail' do
      expect { should contain_bind__record('foo.example.com') 
      }.to raise_error(Puppet::Error, /You need zone_arp if you want the PTR/)
    end
  end

  context 'when using not using ptr' do
    let (:params) { {
      :zone      => 'foo.example.com',
      :hash_data => {},
      :ptr       => false
    } }

    it { should contain_bind__record('foo.example.com') }
  end
end
