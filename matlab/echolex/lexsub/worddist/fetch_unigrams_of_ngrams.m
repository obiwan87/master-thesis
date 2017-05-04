function [unigrams, ngrams_i] = fetch_unigrams_of_ngrams(ngrams, N)

ngrams_i = zeros(size(ngrams,1),N, 'single');
unigrams = cell(N,1);
for i=1:N
    [uni, ~, u_i] = unique(ngrams(:,i));
    ngrams_i(:,i) = u_i;
    unigrams{i} = uni;
end

end

