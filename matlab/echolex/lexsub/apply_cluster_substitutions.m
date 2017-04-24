function [ substitutionMap, clusterWordMap, clusterWordMapVi ] = apply_cluster_substitutions( D, clusters )
%APPLY_SUBSTITUTIONS Summary of this function goes here
%   Detailed explanation goes here

u = D.Vi == 0;
sI = 1:numel(D.V);
sI(u) = find(u);
F = D.termFrequencies();
F_u = F(~u,:);

Vi = D.Vi(D.Vi ~= 0);
C = unique(clusters);
S = zeros(sum(~u), 1);
clusterWordMap = cell(numel(C),1);
clusterWordMapVi = zeros(numel(C),1);
for i=1:numel(C)
    c = C(i);    
    
    b = find(clusters == c);
    Fb = F_u(b,:);
    mi = maxi(Fb.Frequency);    
    clusterWordMap{i} = Fb.Term{mi};
    clusterWordMapVi(i) = Vi(b(mi));
    
    S(b) = b(mi);
end

uf = find(~u);
S = uf(S);
sI(~u) = S;

substitutionMap = containers.Map();

for i=1:numel(sI)
    %fprintf('%s -> %s \n', D.V{i}, D.V{sI(i)});
    substitutionMap(D.V{i}) = D.V{sI(i)};
end


end

