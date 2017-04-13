function [ r, L_ ] = likelihood_ind( F, n, k, L, s)
%LIKELIHOOD_IND Summary of this function goes here
%   Detailed explanation goes here

n_ = n + sum(F.NDocs(s) + F.PDocs(s));
k_ = k + sum(F.PDocs(s));

p_ = k_/n_;
L_ = p_.^k*(1-p_).^(n-k);

r = abs(L-L_);

end

