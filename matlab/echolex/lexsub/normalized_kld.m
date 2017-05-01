function [ K ] = normalized_kld( F, Y )
%NORMALIZED_KLD Summary of this function goes here
%   Detailed explanation goes here

K = kullback_leibler_divergence(F,Y);
K(K<0) = 0;
pd = fitdist(K(:), 'exponential');
lambda = pd.mu^-1;
K = 1 - exp(-lambda*K);

end

