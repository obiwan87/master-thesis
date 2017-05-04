function uni_dists = unigrams_pdist(m, uni_ref, uni_w2v_ref_i)

N = size(uni_ref,1);
uni_dists = cell(N,1);

for i=1:N       
    w2v_ref = uni_w2v_ref_i{i};
    nz_w2v_ref = w2v_ref(w2v_ref~=0);
    
    uni_dist = pdist( m.X(nz_w2v_ref,:), 'cosine');
    
    uni_dists{i} = uni_dist;
end

end
