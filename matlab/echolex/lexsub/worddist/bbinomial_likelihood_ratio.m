function [ B ] = bbinomial_likelihood_ratio( F )
%BINOMIAL_LIKELIHOOD_RATIO Summary of this function goes here
%   Detailed explanation goes here

K = F.PDocs + 1;
J = F.NDocs + 1;
N = K + J;
L = bbinopdf(K,N,K,J);


from = 1;
C = size(F,1);
B = zeros(1, C*(C-1)/2, 'single');

for i=1:C-1
     to = from + C - i - 1;
    
     % Merged probs
     k = K(i) + K(i+1:end);     
     j = J(i) + J(i+1:end);
     
     
     Ls = L(i) .* L(i+1:end);     
     l = bbinopdf(K(i),N(i),k,j).*bbinopdf(K(i+1:end),N(i+1:end),k,j);    
     
     B(from:to) = l./Ls;
     from = to + 1;
end


end

