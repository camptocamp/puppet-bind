#
# ip_reverse.rb
#
module Puppet::Parser::Functions
  newfunction(:net_include, :type => :rvalue, :doc => <<-EOS
included ip address
    EOS
             ) do |arguments|
    require 'ipaddr'

    arguments[0].each do |net|
      if IPAddr.new(net).include?(IPAddr.new(arguments[1]))
        @cur_net = net
      end
    end
    return @cur_net
  end
end

# vim: set ts=2 sw=2 et :
