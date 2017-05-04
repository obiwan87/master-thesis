function ngram_dists = ngrams_pdist2(m, ngrams_ref, ngrams_query, N)

ngrams_ref = fetch_ngrams(ngrams_ref);
ngrams_query = fetch_ngrams(ngrams_query);

%% Make and index of all unigrams and bigrams
[uni_ref,   n_ref_i] = fetch_unigrams_of_ngrams(ngrams_ref,N);
[uni_query, n_query_i] = fetch_unigrams_of_ngrams(ngrams_query,N);

uni_w2v_ref_i   = unigrams_w2v_index(m, ngrams_ref, n_ref_i);
uni_w2v_query_i = unigrams_w2v_index(m, ngrams_query, n_ref_i);

uni_dists = unigrams_pdist2(m, uni_ref, uni_w2v_ref_i, uni_query, uni_w2v_query_i);
ngram_dists = zeros(size(ngrams_ref,1), size(ngrams_query,1), N, 'single');

for i=1:N
    uni_dist = uni_dists{i};
    for j=1:size(ngrams_ref)
        ngram_dists(j,:,i) =  uni_dist(n_ref_i(j,i), n_query_i(:,i));
    end
end

end