
s = 1;

sentence = D.T{s}

m1 = Word2VecModel(D.V, X(Vi,:));

% Entire model
K = 10;
S = cell(K, numel(sentence)*2);
for i=1:numel(sentence)
	[idx, dist] = m1.similar(sentence{i});
    S(:,(i-1)*2+1) = D.V(idx);
    S(:,i*2) = num2cell(F.Frequency(idx));
end
