function [ s ] = nop( name, output )
%NOP Passes input to output
%   Detailed explanation goes here

if nargin < 1
    name = '';
end

if nargin < 2
    output = [];
end

s = pipeline.NoOperation( name, output );

end

