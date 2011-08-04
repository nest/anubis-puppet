
# ZYV

module Puppet::Parser::Functions
    newfunction(:str_concat, :type => :rvalue) do |args|
        flat = args.flatten
        flat.join
    end
end
