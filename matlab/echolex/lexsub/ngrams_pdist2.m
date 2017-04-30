function ngram_dists = ngrams_pdist2(m, ngrams_ref, ngrams_query, N)

ngrams_ref = fetch_ngrams(ngrams_ref);
ngrams_query = fetch_ngrams(ngrams_query);

%% Make and index of all unigrams and bigrams
[uni_ref,   n_ref_i] = fetch_unigrams_of_ngrams(ngrams_ref,N);
[uni_query, n_query_i] = fetch_unigrams_of_ngrams(ngrams_query,N);

uni_w2v_ref_i   = unigrams_w2v_index(m, ngrams_ref);
uni_w2v_query_i = unigrams_w2v_index(m, ngrams_query);

uni_dists = unigrams_pdist2(m, uni_ref, uni_w2v_ref_i, uni_query, uni_w2v_query_i);
ngram_dists = zeros(size(ngrams_ref,1), size(ngrams_ref,1), N);

for i=1:N
    uni_dist = uni_dists{i};
    for j=1:size(ngrams_ref)
        ngram_dists(j,:,i) =  uni_dist(n_ref_i(j,i), n_query_i(:,i));
    end
end

end

function [unigrams, ngrams_i] = fetch_unigrams_of_ngrams(ngrams, N)

ngrams_i = zeros(size(ngrams,1),N);
unigrams = cell(N,1);
for i=1:N
    [uni, ~, u_i] = unique(ngrams(:,i));
    ngrams_i(:,i) = u_i;
    unigrams{i} = uni;
end

end

function uni_dists = unigrams_pdist2(m, uni_ref, uni_w2v_ref_i, uni_query, uni_w2v_query_i)

N = size(uni_ref,1);
uni_dists = cell(N,1);

for i=1:N
    
    u_ref = uni_ref{i};
    u_query = uni_query{i};
    
    w2v_ref = uni_w2v_ref_i{i};
    nz_w2v_ref = w2v_ref(w2v_ref~=0);
    
    w2v_query = uni_w2v_query_i{i};
    nz_w2v_query = w2v_query(w2v_query~=0);
    
    uni_dist_w2v = pdist2( m.X(nz_w2v_ref,:), m.X(nz_w2v_query,:), 'cosine');
    
    % Now we have to extend the distance matrix in order to contain
    % also words that are not in the w2v-model
    
    nz_w2v_ref = w2v_ref~=0;        
    nz_w2v_query = w2v_query~=0;
    z_w2v_ref = w2v_ref == 0;
    z_w2v_query = w2v_query == 0;
    
    [~,ia,ib] = intersect(u_ref(z_w2v_ref), u_query(z_w2v_query));
    
    uni_dist_rest = inf(sum(z_w2v_ref), sum(z_w2v_query));
    ii = sub2ind(size(uni_dist_rest), ia, ib);
    uni_dist_rest(ii) = 0;
    
    uni_dist_buff = Inf(size(u_ref,1), size(u_query,1));    
    uni_dist_buff(1:size(uni_dist_w2v,1),1:size(uni_dist_w2v,2)) = uni_dist_w2v;
    uni_dist_buff(size(uni_dist_w2v,1)+1:end,size(uni_dist_w2v,2)+1:end) = uni_dist_rest;
    
    uni_dist = inf(size(u_ref,1), size(u_query,1));    
    uni_dist(nz_w2v_ref,nz_w2v_query) = uni_dist_buff(1:size(uni_dist_w2v,1),1:size(uni_dist_w2v,2));
    uni_dist(z_w2v_ref, z_w2v_query) = uni_dist_buff(size(uni_dist_w2v,1)+1:end,size(uni_dist_w2v,2)+1:end);
    
    uni_dists{i} = uni_dist;
end

end

function unigrams_w2v_i = unigrams_w2v_index(m, ngrams)
N = size(ngrams,2);
unigrams_w2v_i = cell(N,1);

for i=1:N
    uni = unique(ngrams(:,i));
    uni_w2v_i = zeros(size(uni));
    [~, ia, u_w2v_i] = intersect(uni, m.Terms);
    uni_w2v_i(ia) = u_w2v_i;
    unigrams_w2v_i{i} = uni_w2v_i;
end
end

function [bigrams] = fetch_ngrams(ngrams)

bigrams = cellstr(string(ngrams).split('_'));

end
