function [ o ] = ife(in, c, t, e )
%IFE Summary of this function goes here
%   Detailed explanation goes here

if c(in)
    o = t(in);
else
    o = e(in);
end

end

