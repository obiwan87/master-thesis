function [ c ] = sub2cond( S, row, col)
%SUB2COND Summary of this function goes here
%   Detailed explanation goes here

if isempty(row)
    c = [];    
    return 
end

n = S(1);
sub = [row' col'];
sub = sort(sub, 2, 'descend');

i = sub(:,1);
j = sub(:,2);

c = i -j/2.*(j + 1)+ n.*(j-1);

end

