function [ B ] = bernoulli_divergence_weighted( F, D, a )
%BERNOULLI_DIVERGENCE Summary of this function goes here
%   Detailed explanation goes here

if nargin < 3
    a = 0;
end

weighted = nargin > 1 & a ~= 0;

K = F.PDocs + 1;
J = F.NDocs + 1;
N = K + J;
P = K./N;
L = P.^K;
L = L.*(1-P).^J;

from = 1;
C = size(F,1);
B = zeros(1, C*(C-1)/2, 'single');

for i=1:C-1
     to = from + C - i - 1;
    
     % Merged probs
     k = K(i) + K(i+1:end);     
     j = J(i) + J(i+1:end);
     n = j + k;
     
     % Likelihood of two bernoulli experiments with two "coins"
     Ls = L(i) .* L(i+1:end);
     
     % Lilelihood of two bernoulli experiments with one "coin"
     p = k./n;     
     l = p.^k.*(1-p).^j;     
     
     % Compute priors of model 
     if weighted
         d = D(from:to)/2;
         d = a*d + 1/2*(1-a);
     else
         d = 0.5;
     end
     
     x1 = Ls./l;
     x2 = (d./(1-d))';
     x3 = 1 + x1 .* x2;
     
     % Probability of merged words
     b  = 1 ./ x3;
     
     % Since we want a dissimilarity, we want a probability of 1 to
     % correspond to a dissimilarity of 0
     b = 1 - b;
     
     B(from:to) = b;
     from = to + 1;
end
B(isnan(B)) = Inf;
end
