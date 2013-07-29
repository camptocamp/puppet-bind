require 'spec_helper'
require File.expand_path(File.dirname(__FILE__)) + '/../defines/parameters.rb'

@parameters.each { |k, v|

  describe 'dynamic_bind_zone' do
    let (:facts) { {
      :osfamily        => v['osfamily'],
      :operatingsystem => k
    } }
    describe "should depend on bind::key" do
      it { should contain_file("#{v['dynamic_directory']}/test.tld.conf").with_require(/.*Bind::Key.*update.dynamic.*/i) }
    end

    describe "zone configuration should contain 'type master'" do
      it { should contain_concat__fragment('bind.zones.test.tld').with(
        :content => /type master;/i,
        :target  => "#{v['zones_directory']}/test.tld.conf"
      )}
    end

    describe "zone configuration should contain allow-update" do
      it { should contain_concat__fragment('bind.zones.test.tld').with(
        :content => /allow-update \{ key update.dynamic\.; \};/i,
        :target  => "#{v['zones_directory']}/test.tld.conf"
      )}
    end
  end
}
