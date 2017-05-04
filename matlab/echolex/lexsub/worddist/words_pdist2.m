function D = words_pdist2(m, V_ref, V_query, aggFcn)

if nargin < 4
    aggFcn = @(X) max(X, [], 3);
end

ngrams_ref = cellfun(@(x) strsplit(x, '_'), V_ref, 'UniformOutput', false);
N_ref = cellfun(@(x) numel(x), ngrams_ref);

ngrams_query = cellfun(@(x) strsplit(x, '_'), V_query, 'UniformOutput', false);
N_query = cellfun(@(x) numel(x), ngrams_query);

n = unique(N_ref);

D = inf(numel(V_ref), numel(V_query), 'single');

for i=1:numel(n)
    pos_ref = N_ref==n(i);
    pos_query = N_query==n(i);
    
    n_ref = V_ref(pos_ref);
    n_query = V_query(pos_query);
    
    dist = ngrams_pdist2(m,n_ref,n_query,n(i));
    dist = aggFcn(dist);
    
    D(pos_ref, pos_query) = dist;
end

end