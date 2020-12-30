require 'spec_helper'

describe 'bind::zone' do

  let (:title) { 'domain.tld' }

  let(:pre_condition) do
    "class { 'bind': }"
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
        when 'Suse'
          '/etc/named.d'
        end
      end

      let(:bind_group) do
        case facts[:osfamily]
        when 'Debian'
          'bind'
        when /RedHat|Suse/
          'named'
        end
      end

      # Validate input
      context 'when using a wrong ensure value' do
        let (:params) { {
          :ensure      => 'running'
        } }

        it 'should fail' do
          expect { should contain_concat("#{confdir}/zones/domain.tld.conf")
          }.to raise_error(Puppet::Error, /\$ensure must be either.* got 'running'/)
        end
      end

      context 'when passing an unexpected value to zone_type' do
        let (:params) { {
          :zone_type => 'hello'
        } }

        it 'should fail' do
          expect { should contain_concat("#{confdir}/zones/domain.tld.conf")
          }.to raise_error(Puppet::Error, /Zone type 'hello' not supported\./)
        end
      end

      context 'when passing wrong type for is_dynamic' do
        let (:params) { {
          :is_dynamic => 'goodbye'
        } }

        it 'should fail' do
          expect { should contain_concat("#{confdir}/zones/domain.tld.conf")
          }.to raise_error(Puppet::Error, /"goodbye" is not a boolean\./)
        end
      end

      context 'when zone is a slave with dynamic update enabled' do
        let (:params) { {
          :is_dynamic => true,
          :zone_type  => 'slave'
        } }

        it 'should fail' do
          expect { should contain_concat("#{confdir}/zones/domain.tld.conf")
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
             expect { should contain_concat("#{confdir}/zones/domain.tld.conf")
             }.to raise_error(Puppet::Error, /false is not (a string|an Array)\./)
           end
         end
       end

       context 'when master' do
         context 'when passing contact with spaces' do
           let (:params) { {
             :zone_type    => 'master',
             :zone_contact => 'it has spaces',
             :zone_ns      => ['ns.tld'],
             :zone_serial  => '123456',
             :zone_ttl     => '60'
           } }

           it 'should fail' do
             expect { should contain_concat("#{confdir}/zones/domain.tld.conf")
             }.to raise_error(Puppet::Error, /Wrong contact value for domain\.tld/)
           end
         end

         context 'when passing ns with spaces' do
           let (:params) { {
             :zone_type    => 'master',
             :zone_contact => 'admin@example.com',
             :zone_ns      => ['ns space tld'],
             :zone_serial  => '123456',
             :zone_ttl     => '60'
           } }

           it 'should fail' do
             expect { should contain_concat("#{confdir}/zones/domain.tld.conf")
             }.to raise_error(Puppet::Error, /Failed to parse template bind\/zone-header.erb/)
             #}.to raise_error(Puppet::Error, /Wrong ns value for 'ns space tld'/)
           end
         end

         context 'when passing wrong serial' do
           let (:params) { {
             :zone_type    => 'master',
             :zone_contact => 'admin@example.com',
             :zone_ns      => ['ns.tld'],
             :zone_serial  => 'deadbeef',
             :zone_ttl     => '60'
           } }

           it 'should fail' do
             expect { should contain_concat("#{confdir}/zones/domain.tld.conf")
             }.to raise_error(Puppet::Error, /Wrong serial value for domain\.tld/)
           end
         end

         context 'when passing wrong ttl' do
           let (:params) { {
             :zone_type    => 'master',
             :zone_contact => 'admin.example.com',
             :zone_ns      => ['ns.tld'],
             :zone_serial  => '123456',
             :zone_ttl     => 'abc'
           } }

           it 'should fail' do
             expect { should contain_concat("#{confdir}/zones/domain.tld.conf")
             }.to raise_error(Puppet::Error, /Wrong ttl value for domain\.tld/)
           end
         end
       end


       # Check resources
       context 'when present' do
         context 'when slave' do
           let (:params) { {
             :zone_type    => 'slave',
             :zone_masters => '1.2.3.4',
             :transfer_source => '2.3.4.5',
           } }

           it { should contain_concat("#{confdir}/zones/domain.tld.conf").with({
             :owner => 'root',
             :group => 'root',
             :mode  => '0644'
           }) }
           it { should contain_concat__fragment('bind.zones.domain.tld').with({
             :target  => "#{confdir}/zones/domain.tld.conf",
             :content => "# File managed by puppet\nzone domain.tld IN {\n  type slave;\n  masters { 1.2.3.4; };\n  allow-query { any; };\n    transfer-source 2.3.4.5;\n    forwarders { };\n};\n"
           }) }
         end

         context 'when forward' do
           let (:params) { {
             :zone_type    => 'forward',
             :zone_forwarders => '1.2.3.4',
           } }

           it { should contain_concat("#{confdir}/zones/domain.tld.conf").with({
             :owner => 'root',
             :group => 'root',
             :mode  => '0644'
           }) }
           it { should contain_concat__fragment('bind.zones.domain.tld').with({
             :target  => "#{confdir}/zones/domain.tld.conf",
             :content => "# File managed by puppet\nzone domain.tld IN {\n  type forward;\n  forwarders { 1.2.3.4; };\n};\n"
           }) }
         end

         context 'when master' do
           let (:params) { {
             :zone_type    => 'master',
             :zone_contact => 'admin@example.com',
             :zone_ns      => ['ns.tld', 'ns2.tld'],
             :zone_serial  => '123456',
             :zone_ttl     => '60',
             :zone_notify  => ['1.1.1.1', '2.2.2.2']
           } }

           it { should contain_concat("#{confdir}/zones/domain.tld.conf").with({
             :owner => 'root',
             :group => 'root',
             :mode  => '0644'
           }) }
           it { should contain_concat__fragment('bind.zones.domain.tld').with({
             :target  => "#{confdir}/zones/domain.tld.conf",
             :content => "# File managed by puppet\nzone \"domain.tld\" IN {\n  type master;\n  file \"#{confdir}/pri/domain.tld.conf\";\n  allow-transfer { none; };\n  allow-query { any; };\n  notify yes;\n  also-notify { 1.1.1.1; 2.2.2.2; };\n  forwarders { };\n};\n"
           }) }
           it { should contain_concat("#{confdir}/pri/domain.tld.conf").with({
             :owner => 'root',
             :group => bind_group,
             :mode  => '0664'
           }) }
           it { should contain_concat__fragment('00.bind.domain.tld').with({
             :target  => "#{confdir}/pri/domain.tld.conf",
             :content => "; File managed by puppet\n$TTL 60\n@ IN SOA ns.tld. admin@example.com. (\n      123456  ; serial\n      3h ; refresh\n      1h   ; retry\n      1w; expiracy\n      60 )   ; TTL\n      IN NS ns.tld.\n      IN NS ns2.tld.\n"
           }) }
           it { should contain_file("#{confdir}/pri/domain.tld.conf.d").with({
             :ensure => 'absent'
           }) }
         end
       end

       context 'when absent' do
         let (:params) { {
           :ensure => 'absent'
         } }

         it { should contain_file("#{confdir}/pri/domain.tld.conf").with({
           :ensure => 'absent'
         }) }
         it { should contain_file("#{confdir}/zones/domain.tld.conf").with({
           :ensure => 'absent'
         }) }
       end
    end
  end
end
