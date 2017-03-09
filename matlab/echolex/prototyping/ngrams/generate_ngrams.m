function [ ngrams, scores, frequencies ] = generate_ngrams( D, N )
%NGRAMS Summary of this function goes here
%   Detailed explanation goes here
T = D.T;
I = D.I;
F = D.termFrequencies().Frequency;

ngrams_count = containers.Map('KeyType', 'char', 'ValueType', 'uint32');
ngrams_tokens = containers.Map('KeyType', 'char', 'ValueType', 'any');

warning('off', 'MATLAB:hankel:AntiDiagonalConflict');
for i=1:size(T,1)    
    S = T{i}; %sentence
    SI = I{i};
    n = numel(S);
        
    h = hankel(1:n, 1:N);
    h = h(1:n-N+1,:);
    h = reshape(h, numel(h)/2, 2);
    
    r = S( h );    
    r = arrayfun(@(x) strjoin(r(x,:),'_'), 1:size(r,1),'UniformOutput', false);
    
    for j = 1:numel(r)
        ngram = r{j};
        if ~ngrams_count.isKey(ngram)
            ngrams_count(ngram) = 0;
            ngrams_tokens(ngram) = uint32(SI(h(j,:)));
        end
        
        ngrams_count(ngram) = ngrams_count(ngram) + 1;
    end
end

ngrams = ngrams_count.keys;
scores = zeros(numel(ngrams),1);
frequencies = zeros(numel(ngrams),1);

for i=1:numel(scores)
    ngram = ngrams{i};
    ngram_count = ngrams_count(ngram);
    f = F(ngrams_tokens(ngram));
    scores(i) = double(ngram_count) ./ f(1);
    frequencies(i) = ngram_count;
end

warning('on', 'MATLAB:hankel:AntiDiagonalConflict');


end

