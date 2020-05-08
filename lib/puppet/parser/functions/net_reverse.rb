#
# ip_reverse.rb
#
module Puppet::Parser::Functions
  newfunction(:net_reverse, :type => :rvalue, :doc => <<-EOS
Reversed ip address
    EOS
             ) do |arguments|
    require 'ipaddr'
    if arguments.size != 1
      raise(Puppet::ParseError, 'net_reverse(): Wrong number of arguments ' \
        "given #{arguments.size} for 1")
    end
    start_num = IPAddr.new(arguments[0]).to_range.begin.to_s.split('.')[3]
    end_num = IPAddr.new(arguments[0]).to_range.end.to_s.split('.')[3]
    return "#{start_num}-#{end_num}.#{IPAddr.new(arguments[0]).reverse.to_s.split('.')[1..3].join('.')}"
  end
end

# vim: set ts=2 sw=2 et :
