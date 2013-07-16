require 'spec_helper'
require File.expand_path(File.dirname(__FILE__)) + '/parameters.rb'

@parameters.each { |k, v|
  describe 'bind::key' do
    let (:title) {'update.domain.tld'}
    let (:facts) { {
      :osfamily        => v['osfamily'],
      :operatingsystem => k
    } }

    # Validate input
    context 'when missing secret value' do
      it 'should fail' do
        expect { should contain_concat("#{v['keys_directory']}/update.domain.tld.conf")
        }.to raise_error(Puppet::Error, /Must pass secret to Bind::Key.*/)
      end
    end

    context 'when using a wrong ensure value' do
      let (:params) { {
        :ensure => 'running',
        :secret => 'abcdefg'
      } }

      it 'should fail' do
        expect { should contain_concat("#{v['keys_directory']}/update.domain.tld.conf")
        }.to raise_error(Puppet::Error, /\$ensure must be either.* got 'running'/)
        end
        end

    context 'when passing wrong type for algorithm' do
      let (:params) { {
        :secret    => 'abcdefg',
        :algorithm => ['abcde', 'fghij']
      } }

      it 'should fail' do
        expect { should contain_concat("#{v['keys_directory']}/update.domain.tld.conf")
        }.to raise_error(Puppet::Error, /\["abcde", "fghij"\] is not a string\..+/)
      end
    end

    context 'when passing wrong type for secret' do
      let (:params) { {
        :secret => ['abcde', 'fghij']
      } }

      it 'should fail' do
        expect { should contain_concat("#{v['keys_directory']}/update.domain.tld.conf")
        }.to raise_error(Puppet::Error, /\["abcde", "fghij"\] is not a string\..+/)
      end
    end

  end
}
