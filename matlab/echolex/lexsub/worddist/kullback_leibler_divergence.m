function [D, wordPosteriors] = kullback_leibler_divergence(F,Y)

% Calculates the symmetric kullback_leibler_divergence: 
% P(w_s)*D(P(C|w_s)||P(C|w_s v w_t)) + P(w_t)*D(P(C|w_t)||P(C|w_s v w_t))

nV = single(size(F,1));

K_P = single(F.PDocs);
K_N = single(F.NDocs);

wordPriorsPerClass = zeros(nV,2,'single');
wordPriorsPerClass(:,1) = (1+K_P)./(numel(nV) + sum(K_P));
wordPriorsPerClass(:,2) = (1+K_N)./(numel(nV) + sum(K_N));

priors = [sum(Y)/numel(Y) , sum(~Y)/numel(Y)];
wordPriors = sum(wordPriorsPerClass.*priors,2);

wordPosteriors = (wordPriorsPerClass./sum(wordPriorsPerClass.*priors,2)).*priors;

oneOverPairwisePriorsSum = wordPriors + wordPriors';
oneOverPairwisePriorsSum = 1./oneOverPairwisePriorsSum;

w1orw2_p = wordPriors.*wordPosteriors(:,1); %+ wordPriors'.*wordPosteriors(:,1)';
w1orw2_p = w1orw2_p + w1orw2_p';
w1orw2_p = oneOverPairwisePriorsSum.*w1orw2_p; 

w1orw2_n = wordPriors.*wordPosteriors(:,2); % + wordPriors'.*wordPosteriors(:,2)';
w1orw2_n = w1orw2_n + w1orw2_n';
w1orw2_n = oneOverPairwisePriorsSum.*w1orw2_n;

D1 = log2(single(wordPosteriors(:,1)))- log2(single(w1orw2_p));
D1 = single(wordPosteriors(:,1)) .* D1;

D2 = log2(single(wordPosteriors(:,2)))- log2(single(w1orw2_n));
D2 = single(wordPosteriors(:,2)) .* D2;

D = D1 + D2;
D = wordPriors.*D;
D = D + D';

end