function [ substitutionMap, clusterWordMap ] = apply_cluster_substitutions_bigrams( D, clusters )

substitutionMap = containers.Map;

V = D.V(D.B);
F_b = D.termFrequencies();
F_b = F_b(D.B,:);

C = unique(clusters);
clusterWordMap = cell(numel(C),1);

for i=1:numel(C)
    b = clusters == C(i);
    bigrams = V(b);
    substitute = bigrams{maxi(F_b.Frequency(b))};
    %F_b(b,:)
    clusterWordMap{i} = substitute;
    for j=1:numel(bigrams)
        substitutionMap(bigrams{j}) = substitute;
    end
end
end

