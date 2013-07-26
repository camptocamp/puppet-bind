require 'spec_helper'
require File.expand_path(File.dirname(__FILE__)) + '/parameters.rb'

@parameters.each { |k, v|
  describe 'bind::zone' do
    let (:title) { 'domain.tld' }
    let (:facts) { {
      :osfamily        => v['osfamily'],
      :operatingsystem => k
    } }

    # Validate input
    context 'when using a wrong ensure value' do
      let (:params) { {
        :ensure      => 'running'
      } }

      it 'should fail' do
        expect { should contain_concat("#{v['zones_directory']}/domain.tld.conf")
        }.to raise_error(Puppet::Error, /\$ensure must be either.* got 'running'/)
        end
        end

    context 'when passing wrong type for is_slave' do
      let (:params) { {
        :is_slave => 'hello'
      } }

      it 'should fail' do
        expect { should contain_concat("#{v['zones_directory']}/domain.tld.conf")
        }.to raise_error(Puppet::Error, /"hello" is not a boolean\./)
      end
    end

    context 'when passing wrong type for is_dynamic' do
      let (:params) { {
        :is_dynamic => 'goodbye'
      } }

      it 'should fail' do
        expect { should contain_concat("#{v['zones_directory']}/domain.tld.conf")
        }.to raise_error(Puppet::Error, /"goodbye" is not a boolean\./)
      end
    end

    context 'when zone is a slave with dynamic update enabled' do
      let (:params) { {
        :is_dynamic => true,
        :is_slave   => true
      } }

      it 'should fail' do
        expect { should contain_concat("#{v['zones_directory']}/domain.tld.conf")
        }.to raise_error(Puppet::Error, /Zone 'domain\.tld' cannot be slave AND dynamic!/)
      end
    end

    # Test all string parameters
    [:ensure, :zone_ttl, :zone_contact, :zone_serial, :zone_refresh,
      :zone_retry, :zone_expiracy, :zone_ns,
      :zone_origin].each do |p|
      context "when passing wrong type for #{p}" do
        let (:params) { {
          p => false
        } }

        it 'should fail' do
          expect { should contain_concat("#{v['zones_directory']}/domain.tld.conf")
          }.to raise_error(Puppet::Error, /false is not a string\./)
        end
      end
      end

    context 'when master' do
      context 'when passing contact with spaces' do
        let (:params) { {
          :is_slave     => false,
          :zone_contact => 'it has spaces',
          :zone_ns      => 'ns.tld',
          :zone_serial  => '123456',
          :zone_ttl     => '60'
        } }

        it 'should fail' do
          expect { should contain_concat("#{v['zones_directory']}/domain.tld.conf")
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
          expect { should contain_concat("#{v['zones_directory']}/domain.tld.conf")
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
          expect { should contain_concat("#{v['zones_directory']}/domain.tld.conf")
          }.to raise_error(Puppet::Error, /Wrong serial value for domain\.tld/)
        end
      end

      context 'when passing wrong ttl' do
        let (:params) { {
          :is_slave     => false,
          :zone_contact => 'admin.example.com',
          :zone_ns      => 'ns.tld',
          :zone_serial  => '123456',
          :zone_ttl     => 'abc'
        } }

        it 'should fail' do
          expect { should contain_concat("#{v['zones_directory']}/domain.tld.conf")
          }.to raise_error(Puppet::Error, /Wrong ttl value for domain\.tld/)
        end
      end
    end


    # Check resources
    context 'when present' do
      context 'when slave' do
        let (:params) { {
          :is_slave     => true,
          :zone_masters => '1.2.3.4'
        } }

        it { should contain_concat("#{v['zones_directory']}/domain.tld.conf").with(
          :owner => 'root',
          :group => 'root',
          :mode  => '0644'
        ) }
        it { should contain_concat__fragment('bind.zones.domain.tld').with(
          :ensure  => 'present',
          :target  => "#{v['zones_directory']}/domain.tld.conf",
          :content => "# File managed by puppet\nzone domain.tld IN {\n  type slave;\n    masters { 1.2.3.4; };\n    allow-query { any; };\n};\n"
        ) }
          end

      context 'when master' do
        let (:params) { {
          :is_slave     => false,
          :zone_contact => 'admin@example.com',
          :zone_ns      => 'ns.tld',
          :zone_serial  => '123456',
          :zone_ttl     => '60'
        } }

        it { should contain_concat("#{v['zones_directory']}/domain.tld.conf").with(
          :owner => 'root',
          :group => 'root',
          :mode  => '0644'
        ) }
        it { should contain_concat__fragment('bind.zones.domain.tld').with(
          :ensure  => 'present',
          :target  => "#{v['zones_directory']}/domain.tld.conf",
          :content => "# File managed by puppet\nzone \"domain.tld\" IN {\n  type master;\n  file \"#{v['pri_directory']}/domain.tld.conf\";\n  allow-transfer { none; };\n  allow-query { any; };\n  notify yes;\n};\n"
        ) }
        it { should contain_concat("#{v['pri_directory']}/domain.tld.conf").with(
          :owner => 'root',
          :group => v['bind_group'],
          :mode  => '0664'
        ) }
        it { should contain_concat__fragment('00.bind.domain.tld').with(
          :ensure  => 'present',
          :target  => "#{v['pri_directory']}/domain.tld.conf",
          :content => "; File managed by puppet\n$TTL 60\n@ IN SOA domain.tld. admin@example.com. (\n      123456  ; serial\n      3h ; refresh\n      1h   ; retry\n      1w; expiracy\n      60 )   ; TTL\n      IN NS ns.tld.\n$ORIGIN .\n"
        ) }
        it { should contain_file("#{v['pri_directory']}/domain.tld.conf.d").with(
          :ensure => 'absent'
        ) }
          end
    end

    context 'when absent' do
      let (:params) { {
        :ensure => 'absent'
      } }

      it { should contain_file("#{v['pri_directory']}/domain.tld.conf").with(
        :ensure => 'absent'
      ) }
      it { should contain_file("#{v['zones_directory']}/domain.tld.conf").with(
        :ensure => 'absent'
      ) }
        end

    end
}
