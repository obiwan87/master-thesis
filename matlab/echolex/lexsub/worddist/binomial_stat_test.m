function [ B ] = binomial_stat_test( F )
%BERNOULLI_DIVERGENCE Summary of this function goes here
%   Detailed explanation goes here

K = F.PDocs + 1;
J = F.NDocs + 1;
N = K + J;
P = K./N;

from = 1;
C = size(F,1);
B = zeros(1, C*(C-1)/2, 'single');

for i=1:C-1
     to = from + C - i - 1;
    
     % Merged probs
     k = K(i) + K(i+1:end);     
     j = J(i) + J(i+1:end);
     n = j + k;
     p = k./n;
     
     x1 = P(i) - P(i+1:end);
     x2 = p.*(1-p);
     x3 = 1./N(i) + 1./N(i+1:end);
     x4 = sqrt(x2 .* x3);
     z = x1 ./ x4;
     c = normcdf(abs(z))*2 - 1;
     B(from:to) = c;
     from = to + 1;
end
end
