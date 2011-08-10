# generates a arpa zone from a normal ip address
#
# example usage
# generate_arpa_zone("10.11.12.13") - returns 12.11.10.in-addr.arpa

module Puppet::Parser::Functions
    newfunction(:generate_arpa_zone, :type => :rvalue) do |args|
      as_array = args[0].split('.')
      as_array.slice!(-1)
      "#{as_array.reverse.join(".")}.in-addr.arpa"
    end
end
