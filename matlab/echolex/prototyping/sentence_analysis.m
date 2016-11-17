
s = 1;

sentence = D.T{s}

V = terms;
m1 = Word2VecModel(V, X);

% Entire model
K = 10;
S = cell(K, numel(sentence)*2);
N = unique(nns(:));
F = histc(nns(:), N);
for i=1:numel(sentence)
	[idx, dist] = m1.similar(sentence{i}, K);
    
    I = arrayfun(@(x) find(x==N),idx,'UniformOutput', true);
    f = F(I);
    [~, ii] = sort(f, 'descend');
    S(:,(i-1)*2+1) = V(idx(ii));
    S(:,i*2) = num2cell(f(ii));
end