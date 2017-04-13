function [ c ] = sub2cond( S, row, col)
%SUB2COND Summary of this function goes here
%   Detailed explanation goes here

assert(S(1) == S(2));

n = S(1);
sub = [row col];
sub = sort(sub, 'descend');

i = sub(1);
j = sub(2);

c = sum((n-j+1):(n-1))+(i-j);

end

