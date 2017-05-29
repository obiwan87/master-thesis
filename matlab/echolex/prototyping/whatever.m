%Counts

% Word 1
k1 = 15;
n1 = 20;
d = 0.1;
% Word 2
k2 = 3;
n2 = 20;


% Bayes factor
K1 = bbinopdf(k1,n1,k1,n1-k1)*bbinopdf(k2,n2,k2,n2-k2) % probability of model 1 given param 
K2 = bbinopdf(k2,n2,k1+k2, (n1-k1)+(n2-k2))*bbinopdf(k1,n1,k1+k2, (n1-k1)+(n2-k2)) %probability of model 2 given param

L1 = binopdf(k1,n1,k1/n1)*binopdf(k2,n2,k2/n2);
L2 = binopdf(k2,n2,(k1+k2)/(n1+n2))*binopdf(k1,n1,(k1+k2)/(n1+n2));

%likelihood ratio

% probabilities

%Stage 0
p0 = L2*(1-d)/(L1*d + (1-d)*L2)

%Stage 1
p1 = K2*(1-d)/(d*K1 + (1-d)*K2)

%dist

dist0 = 1-p0
dist1 = 1-p1



N = 3;
best_combination = {[1 1 ], [2 2 ], [3 3], [4 4]};
params_ngrams = allcomb([0.3:0.1:0.4], [0.3:0.1:0.4], [0.8:0.1:1], [ 0.3:0.4:0.7]);
param_combinations = cell(size(params_ngrams));

for i=1:size(params_ngrams,1)
   for j = 1:size(params_ngrams,2)        
       param_combinations{i,j} = zeros(1,N);
       for k=1:N-1       
       param_combinations{i,j}(k) = best_combination{j}(k);
       end
       param_combinations{i,j}(N) = params_ngrams(i,j);
   end
end
