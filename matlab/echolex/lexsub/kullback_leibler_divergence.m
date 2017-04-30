function D = kullback_leibler_divergence(W, onlyWord2Vec)

if nargin < 2
    onlyWord2Vec = false;
end

F = W.termFrequencies();
nV = numel(W.V);
if onlyWord2Vec
    F = F(W.Vi~=0,:);
    nV = sum(W.Vi~=0);
end

K_P = F.PDocs;
K_N = F.NDocs;

wordPriorsPerClass = zeros(nV,2);
wordPriorsPerClass(:,1) = (1+K_P)./(numel(W.V) + sum(K_P));
wordPriorsPerClass(:,2) = (1+K_N)./(numel(W.V) + sum(K_N));

priors = [sum(W.Y)/numel(W.Y) , sum(~W.Y)/numel(W.Y)];
wordPriors = sum(wordPriorsPerClass.*priors,2);

wordPosteriors = (wordPriorsPerClass./sum(wordPriorsPerClass.*priors,2)).*priors;

oneOverPairwisePriorsSum = wordPriors + wordPriors';
oneOverPairwisePriorsSum = 1./oneOverPairwisePriorsSum;

w1orw2_p = wordPriors.*wordPosteriors(:,1) + wordPriors'.*wordPosteriors(:,1)';
w1orw2_p = oneOverPairwisePriorsSum.*w1orw2_p; 

w1orw2_n = wordPriors.*wordPosteriors(:,2) + wordPriors'.*wordPosteriors(:,2)';
w1orw2_n = oneOverPairwisePriorsSum.*w1orw2_n;

D1 = log2(single(wordPosteriors(:,1)))- log2(single(w1orw2_p));
D1 = single(wordPosteriors(:,1)) .* D1;

D2 = log2(single(wordPosteriors(:,2)))- log2(single(w1orw2_n));
D2 = single(wordPosteriors(:,2)) .* D2;

D = D1 + D2;
D = wordPriors.*D;
D = D + D';

end