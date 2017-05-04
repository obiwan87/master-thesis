function [ ngram_dists ] = ngrams_pdist( m, ngrams, N, aggFcn)

if nargin < 4
    aggFcn = @(X) max(X, [], 1);
end

ngrams = fetch_ngrams(ngrams);

%% Make and index of all unigrams and bigrams
[uni, n_i] = fetch_unigrams_of_ngrams(ngrams,N);
[uni_w2v_i, n_w2v_i]  = unigrams_w2v_index(m, ngrams, n_i);

uni_dists = unigrams_pdist(m, uni, uni_w2v_i);
S = size(ngrams,1);
ngram_dists = inf(1,S*(S-1)/2, 'single');

ngramsCount = size(ngrams,1);

from = 1;
for j=1:ngramsCount-1    
    to = from + ngramsCount - j - 1;
    
    range = from:to;
    d = inf(N, numel(range), 'single');
    for i=1:N        
        S1 = sum(uni_w2v_i{i} ~= 0);
        r = n_w2v_i(j,i);
        
        if r ~= 0
            other = n_w2v_i((j+1):ngramsCount,i);
            
            q = other ~= 0 & other ~= r;
            
            range1 = range(q) - from + 1;
            query = other(q)';

            ii = sub2cond(S1, repmat(r, 1, numel(query)), query);            
            d(i,range1) = uni_dists{i}(ii);

        end
        r = n_i(j,i);
        other = n_i((j+1):ngramsCount,i);
        q = other == r;
        range1 = range(q) - from + 1;
        d(i,range1) = 0; 
    end
    ngram_dists(range) = aggFcn(d);
    from = to + 1;
end


end

