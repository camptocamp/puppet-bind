require 'spec_helper'

describe 'bind::record' do
  let (:title) { 'CNAME foo.example.com' }
  let (:facts) { {
    :osfamily        => 'Debian',
    :operatingsystem => 'Debian'
  } }

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
end
