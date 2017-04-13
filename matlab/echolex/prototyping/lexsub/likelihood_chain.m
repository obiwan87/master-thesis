function [ L, LL ] = likelihood_chain( F, p, c,P)
%LIKELIHOOD_ Summary of this function goes here
%   Detailed explanation goes here

n = F.NDocs(c) + F.PDocs(c);
k = F.PDocs(c);

%lognoverk = arrayfun(@(x) log(nchoosek(n(x), k(x))), 1:size(n,1))';
lognoverk = arrayfun(@(x) lognchoosek(n(x), k(x)), 1:size(n,1))';
LL = sum(lognoverk + k.*log(p) + log(1-p).*(n-k));
L = exp(LL);

end

