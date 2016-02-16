require 'spec_helper'

describe 'bind::acl' do
  let(:pre_condition) do
    "class {'::bind': }"
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
        let (:title) {'wrong acl'}
        let (:params) {{
          :ensure => 'foo',
          :acls   => ['any'],
        }}

        it 'should fail' do
          expect { should contain_file('wrong acl') }.to raise_error(Puppet::Error, /does not match/)
        end
      end

      context 'when passing wrong acls type' do
        let (:title) {'wrong acl'}
        let (:params) {{
          :ensure => 'present',
          :acls   => 1,
        }}

        it 'should fail' do
          expect { should contain_file('wrong acl') }.to raise_error(Puppet::Error, /is not an Array/)
        end
      end

      context 'correct acl' do
        let (:title) {'good acl'}
        let (:params) {{
          :ensure => 'present',
          :acls   => ['!192.168.10.0/24', 'any'],
        }}

        it { should contain_file('good acl').with({
          :content => "acl good-acl {\n  !192.168.10.0/24;\n  any;\n};\n",
          :ensure  => 'file',
          :path    => "#{confdir}/acls/good-acl",
        }) }
      end


    end
  end
end
