function [ B ] = bernoulli_divergence( F )
%BERNOULLI_DIVERGENCE Summary of this function goes here
%   Detailed explanation goes here

K = F.PDocs + 1;
N = K + F.NDocs + 1;
P = single(K./N);

L = P.^K.*(1-P).^(N-K);
L = pdist(L, @times);

k = pdist(K, @plus);
n = pdist(N, @plus);
P_ = k./n;
L_ = P_.^k.*(1-P_).^(n-k);
B = L_ ./ (L + L_);
B = 1-2*B;

end
