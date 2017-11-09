function [ acc, p, predictions, precision, recall] = trainTestNB( D, WC, trainingIdx, testIdx )
%TRAINTESTNB Summary of this function goes here
%   Detailed explanation goes here

nbmodel = fitcnb(WC(trainingIdx,:), D.Y(trainingIdx), 'distribution', 'mn');
[predictions, posteriors] = predict(nbmodel, WC(testIdx,:));

acc = sum(predictions == D.Y(testIdx)) / numel(predictions);
ii = sub2ind(size(posteriors), 1:size(posteriors,1), (D.Y(testIdx)+1)');
p = mean(posteriors(ii));
truths = D.Y(testIdx);
[~, precision, recall] = qualityMeasures(truths, predictions);

end

