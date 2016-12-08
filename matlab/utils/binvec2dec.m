function [ d ] = binvec2dec( b )
%BINVEC2DEC Interprets a vector of zeros and ones as a binary number 
% and transforms it to a decimal number.
%   Detailed explanation goes here

s = unique(b);
if sum(s < 0 | s > 1) > 0
    error('Input vector contains numbers other than 0 or 1');
end

d = zeros(size(b,1),1);
p = 2.^(0:size(b,2)-1);
for i=1:size(b,1)
    d(i) = sum(p.*b(i,end:-1:1));
end

end

