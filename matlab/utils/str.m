function [ s ] = str( m )
%STR Summary of this function goes here
%   Detailed explanation goes here

if isnumeric(m)
    s = num2str(m);
elseif isa(m, 'function_handle')
    s = func2str(m);
elseif ischar(m)
    s = m;
else
    error('Data type not supported');
end

end

