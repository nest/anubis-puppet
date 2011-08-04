# ZYV

module Puppet::Parser::Functions
    newfunction(:trim, :type => :rvalue) do |args|
        args[0].strip
    end
end
