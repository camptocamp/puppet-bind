#
# bind_check_hostname.rb
#
module Puppet::Parser::Functions
  newfunction(:bind_check_hostname, :type => :rvalue, :doc => <<-EOS
Prepare checked string for *is_domain_name()* (from stdlib) by removing /^\*\./
if present. *is_domain_name()* doesn't want any wildcard, which makes sense in
most cases.
    EOS
  ) do |arguments|

    if (arguments.size != 1) then
      raise(Puppet::ParseError, "bind_check_hostname(): Wrong number of arguments "+
        "given #{arguments.size} for 1")
    end

    record = arguments[0]

    # Allows '@'
    return true if record == '@'

    # Allow wildcard only at the begining
    # As we're calling stdlib's *is_domain_name()*
    # which doesn't accept wildcards, we just clean it
    # from the record, and pass this new string to
    # *is_domain_name()*
    domain = record.sub(/^\*\./, '')
    return function_is_domain_name([domain])
  end
end

# vim: set ts=2 sw=2 et :
