# returns the last number in a ip address
#
# example usage
# get_last_number_from_ip("10.11.12.13") - returns 13

module Puppet::Parser::Functions
    newfunction(:get_last_number_from_ip, :type => :rvalue) do |args|
      as_array = args[0].split('.')
      as_array.last
    end
end
