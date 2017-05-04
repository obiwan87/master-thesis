function [unigrams_w2v_i, ngrams_w2v_i] = unigrams_w2v_index(m, ngrams, ngrams_i)
N = size(ngrams,2);
unigrams_w2v_i = cell(N,1);
ngrams_w2v_i = zeros(size(ngrams), 'single');

for i=1:N
    uni = unique(ngrams(:,i));
    uni_w2v_i = zeros(size(uni));
    
    [~, ia, u_w2v_i] = intersect(lower(uni), lower(m.Terms));
    uni_w2v_i(ia) = u_w2v_i;
    
    [~, ia, u_w2v_i] = intersect(uni, m.Terms);
    uni_w2v_i(ia) = u_w2v_i;
    
    unigrams_w2v_i{i} = uni_w2v_i;        
    
    ngrams_w2v_i(:,i) = uni_w2v_i(ngrams_i(:,i));
    
    c = zeros(size(uni));
    c(uni_w2v_i~=0) = 1:sum(uni_w2v_i~=0);
    
    ngrams_w2v_i(:,i) = c(ngrams_i(:,i));    
    
end
end