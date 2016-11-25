function [ p ] = struct2params( s )
%STRUCT2PARAMETERS Summary of this function goes here
%   Detailed explanation goes here


fs = fieldnames(s);

p = cell(1,2*numel(fs));
p(1:2:end) = fs(:);

for k=1:numel(fs)
    p{2*k} = s.(fs{k});
end

end

