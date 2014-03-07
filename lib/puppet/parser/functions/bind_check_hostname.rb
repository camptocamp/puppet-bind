#
# bind_check_hostname.rb
#
module Puppet::Parser::Functions
  newfunction(:bind_check_hostname, :type => :rvalue, :doc => <<-EOS
Prepare checked string for *is_domain_name()* (from stdlib) by removing /^\*\.?/
if present. *is_domain_name()* doesn't want any wildcard, which makes sense in
most cases.
Usage: bind_check_hostname(hostname, type)
    EOS
  ) do |arguments|

    if (arguments.size != 2) then
      raise(Puppet::ParseError, "bind_check_hostname(): Wrong number of arguments "+
        "given #{arguments.size} for 2")
    end

    record = arguments[0]
    type = arguments[1]

    # Allows '@'
    return true if record == '@'
    
    # All is allowed for SRV and TXT record types
    return true if type == 'SRV'
    return true if type == 'TXT'

    # Allow wildcard only at the begining
    # As we're calling stdlib's *is_domain_name()*
    # which doesn't accept wildcards, we just clean it
    # from the record, and pass this new string to
    # *is_domain_name()*
    domain = record.sub(/^\*\.?/, '')

    # Nothing left to check, and is_domain_name fails empty
    return true if domain == ''

    return function_is_domain_name([domain])
  end
end

# vim: set ts=2 sw=2 et :
