require 'spec_helper'

describe 'dynamic_bind_zone' do
  let (:facts) { {
    :osfamily        => 'Debian',
    :operatingsystem => 'Debian'
  } }
  describe "should depend on bind::key" do
    it { should contain_concat("/etc/bind/dynamic/test.tld.conf").with_require(/.*Bind::Key.*update.dynamic.*/i) }
  end

  describe "zone configuration should contain 'type master'" do
    it { should contain_concat__fragment('bind.zones.test.tld').with(
      :content => /type master;/i,
      :target  => '/etc/bind/zones/test.tld.conf'
    )}
  end

  describe "zone configuration should contain allow-update" do
    it { should contain_concat__fragment('bind.zones.test.tld').with(
      :content => /allow-update \{ key update.dynamic\.; \};/i,
      :target  => '/etc/bind/zones/test.tld.conf'
    )}
  end
end
