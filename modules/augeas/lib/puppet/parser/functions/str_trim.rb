# ZYV

module Puppet::Parser::Functions
    newfunction(:str_trim, :type => :rvalue) do |args|
        args[0].strip
    end
end
