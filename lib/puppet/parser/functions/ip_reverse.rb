#
# ip_reverse.rb
#
module Puppet::Parser::Functions
  newfunction(:ip_reverse, :type => :rvalue, :doc => <<-EOS
Reversed ip address
    EOS
             ) do |arguments|
    require 'ipaddr'

    if arguments.size != 1
      raise(Puppet::ParseError, 'ip_reverse(): Wrong number of arguments ' \
        "given #{arguments.size} for 1")
    end
    return IPAddr.new(arguments[0]).reverse
  end
end

# vim: set ts=2 sw=2 et :
