# generates a arpa entry from a normal ip address
#
# example usage
# generate_arpa("10.11.12.13") - returns 12.11.10.in-addr.arpa

module Puppet::Parser::Functions
    newfunction(:generate_arpa, :type => :rvalue) do |args|
      as_array = args[0].split('.')
      as_array.slice!(0)
      "#{as_array.reverse.join(".")}.in-addr.arpa"
    end
end
