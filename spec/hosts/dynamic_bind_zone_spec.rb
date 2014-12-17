require 'spec_helper'

describe 'dynamic_bind_zone' do

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

      describe "should depend on bind::key" do
        it { should contain_file("#{confdir}/dynamic/test.tld.conf").with_require(/.*Bind::Key.*update.dynamic.*/i) }
      end

      describe "zone configuration should contain 'type master'" do
        it { should contain_concat__fragment('bind.zones.test.tld').with(
          :content => /type master;/i,
          :target  => "#{confdir}/zones/test.tld.conf"
        )}
      end

      describe "zone configuration should contain allow-update" do
        it { should contain_concat__fragment('bind.zones.test.tld').with(
          :content => /allow-update \{ key update.dynamic\.; \};/i,
          :target  => "#{confdir}/zones/test.tld.conf"
        )}
      end
    end
  end
end
