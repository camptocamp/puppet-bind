require 'spec_helper'
require File.expand_path(File.dirname(__FILE__)) + '/parameters.rb'

@parameters.each { |k, v|
  describe 'bind::a' do
    let (:title) { 'foo.example.com' }
    let (:facts) { {
      :osfamily        => v['osfamily'],
      :operatingsystem => k
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

    context 'when passing wrong type for zone' do
      let (:params) { {
        :zone      => ['foo.example.com'],
        :hash_data => {},
      } }

      it 'should fail' do
        expect { should contain_bind__record('foo.example.com')
        }.to raise_error(Puppet::Error, /\["foo.example.com"\] is not a string\./)
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

    context 'when passing wrong type for hash_data' do
      let (:params) { {
        :zone      => 'foo.example.com',
        :hash_data => 'bar',
      } }

      it 'should fail' do
        expect { should contain_bind__record('foo.example.com')
        }.to raise_error(Puppet::Error, /"bar" is not a Hash\./)
      end
    end

    context 'when passing wrong type for zone_arpa' do
      let (:params) { {
        :zone      => 'foo.example.com',
        :hash_data => {},
        :zone_arpa => ['bar']
      } }

      it 'should fail' do
        expect { should contain_bind__record('foo.example.com')
        }.to raise_error(Puppet::Error, /\["bar"\] is not a string\./)
      end
    end

    context 'when passing wrong type for ptr' do
      let (:params) { {
        :zone      => 'foo.example.com',
        :hash_data => {},
        :ptr       => 'false',
      } }

      it 'should fail' do
        expect { should contain_bind__record('foo.example.com')
        }.to raise_error(Puppet::Error, /"false" is not a boolean\./)
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
        }.to raise_error(Puppet::Error, /You need zone_arpa if you want the PTR/)
      end
    end

    context 'when using not using ptr' do
      let (:params) { {
        :zone      => 'foo.example.com',
        :hash_data => {},
        :ptr       => false
      } }

      it { should contain_bind__record('foo.example.com').with(
        :ensure           => 'present',
        :zone             => 'foo.example.com',
        :record_type      => 'A',
        :hash_data        => {},
        :content_template => nil
      ) }
        end

    context 'when using using ptr' do
      let (:params) { {
        :zone      => 'foo.example.com',
        :hash_data => {},
        :ptr       => true,
        :zone_arpa => 'foobar.arpa'
      } }

      it { should contain_bind__record('foo.example.com').with(
        :ensure           => 'present',
        :zone             => 'foo.example.com',
        :record_type      => 'A',
        :hash_data        => {},
        :content_template => nil
      ) }

      it { should contain_bind__record('PTR foo.example.com').with(
        :ensure           => 'present',
        :zone             => 'foobar.arpa',
        :record_type      => 'PTR',
        :ptr_zone         => 'foo.example.com',
        :hash_data        => {},
        :content_template => nil
      ) }
        end
  end
}
