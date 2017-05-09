function [ B ] = bernoulli_divergence( F )
%BERNOULLI_DIVERGENCE Summary of this function goes here
%   Detailed explanation goes here

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
     
     Ls = L(i) .* L(i+1:end);

     p = k./n;
     l = p.^k.*(1-p).^j;     
     b  = l ./ (Ls + l);
     b = 1 - 2*b;
     B(from:to) = b;
     from = to + 1;
end
end
