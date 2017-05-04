function D = words_pdist(m, V, aggFcn)

if nargin < 4
    aggFcn = @(X) max(X, [], 3);
end

ngrams = cellfun(@(x) strsplit(x, '_'), V, 'UniformOutput', false);
N = cellfun(@(x) numel(x), ngrams);

n = unique(N);

D = inf(numel(V), numel(V_query), 'single');

for i=1:numel(n)
    pos_ref = N==n(i);
    pos_query = N_query==n(i);
    
    n_ref = V(pos_ref);
    n_query = V_query(pos_query);
    
    dist = ngrams_pdist2(m,n_ref,n_query,n(i));
    dist = aggFcn(dist);
    
    D(pos_ref, pos_query) = dist;
end

end