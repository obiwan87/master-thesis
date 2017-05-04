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
    
    uni_dist_rest = inf(sum(z_w2v_ref), sum(z_w2v_query), 'single');
    ii = sub2ind(size(uni_dist_rest), ia, ib);
    uni_dist_rest(ii) = 0;
    
    uni_dist = Inf(size(u_ref,1), size(u_query,1), 'single');    
    uni_dist(nz_w2v_ref,nz_w2v_query) = uni_dist_w2v;
    uni_dist(z_w2v_ref,z_w2v_query) = uni_dist_rest;   
    
    uni_dists{i} = uni_dist;
end

end
