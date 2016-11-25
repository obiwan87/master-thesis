function [ o ] = emptyas( x, s )
%EMPTYAS Maps empty matrices to value s

if nargin < 2
    s = 0;
end

if isempty(x)
    o = s;
else
    o = x;
end

end

