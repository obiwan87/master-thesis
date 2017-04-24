function [ ll, probabilities ] = loglikelihood( nb, D, sentence )
%LOGLIKELIHOOD Summary of this function goes here
%   Detailed explanation goes here

if ischar(sentence)
    sentence = strsplit(sentence, ' ');
end

matches = string(D.V) == string(sentence);
matches = arrayfun(@(x) find(matches(:,x)), 1:size(matches,2));

probabilities = log(cell2mat(nb.DistributionParameters(:,matches)));

ll = log(nb.Prior)' + sum(probabilities,2);


end

