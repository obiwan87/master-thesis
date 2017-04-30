function [ K ] = normalized_kld( EW, onlyWord2Vec)
%NORMALIZED_KLD Summary of this function goes here
%   Detailed explanation goes here

if nargin < 2
    onlyWord2Vec = true;
end

K = kullback_leibler_divergence(EW, onlyWord2Vec);
K(K<0) = 0;
pd = fitdist(K(:), 'exponential');
lambda = pd.mu^-1;
K = 1 - exp(-lambda*K);

end

