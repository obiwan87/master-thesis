function [ s ] = nop( name )
%NOP Passes input to output
%   Detailed explanation goes here

if nargin < 1
    name = '';
end

s = pipeline.NoOperation( name );

end

