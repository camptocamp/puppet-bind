require 'spec_helper'

describe 'bind::view' do
  let(:pre_condition) do
    "class {'::bind': }"
  end

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(concat_basedir: '/var/lib/puppet/concat')
      end

      let(:confdir) do
        case facts[:osfamily]
        when 'Debian'
          '/etc/bind'
        when 'RedHat'
          '/etc/named'
        end
      end

      context 'my view' do
        let(:title) { 'my view' }

        it {
          is_expected.to contain_file("#{confdir}/views/my-view.view").with(ensure: 'file',
                                                                            content: "view \"my-view\" {\n  recursion no;\n  include \"#{confdir}/views/my-view.zones\";\n};\n")
          is_expected.to contain_concat("#{confdir}/views/my-view.zones")
        }
      end
    end
  end
end
