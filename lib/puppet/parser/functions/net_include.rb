#
# ip_reverse.rb 
#
module Puppet::Parser::Functions
  newfunction(:net_include, :type => :rvalue, :doc => <<-EOS
included ip address
    EOS
  ) do |arguments|
    require 'ipaddr'; 

    arguments[0].each { |net| if IPAddr.new(net).include?(IPAddr.new(arguments[1])); @cur_net=net; end  }
    if @cur_net.nil?; return nil ; else return @cur_net; end
  end
end

# vim: set ts=2 sw=2 et :
