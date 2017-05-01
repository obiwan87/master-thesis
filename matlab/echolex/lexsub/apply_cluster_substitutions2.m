function [ substitutionMap, clusterWordMap] = apply_cluster_substitutions2( F, clusters )
%APPLY_SUBSTITUTIONS Summary of this function goes here
%   Detailed explanation goes here

C = unique(clusters);

clusterWordMap = cell(numel(C),1);

for i=1:numel(C)
    c = C(i);        
    b = clusters == c;
    Fb = F(b,:);
    mi = maxi(Fb.Frequency);    
    clusterWordMap{i} = Fb.Term{mi};
end


substitutionMap = containers.Map();
for i=1:size(F,1)    
    substitutionMap(F.Term{i}) = clusterWordMap{clusters(i)};
end


end

