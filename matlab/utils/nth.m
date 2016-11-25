function [ e ] = nth( s, n )
%nth n-th element of a cell or matrix (linear subscript)

if numel(s) > 0
    if iscell(s)
        e = s{n};
    elseif(isnumeric(s))
        e = s(n);
    else
        error('Data Type of ''s'' not supported');
    end
else
    e = [];
end
end

