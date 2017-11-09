function [ acc, p, predictions, precision, recall ] = trainTestNBSVM( D, trainingIdx, testIdx, p)

if nargin < 4
    p = 0;
end
params = struct('dictsize', numel(D.V), 'trainp', p, 'testp', p, 'C', 1);
model = trainMNBSVM(D.I(trainingIdx)',~D.Y(trainingIdx)', params);
truths = ~D.Y(testIdx)';
[acc, predictions, p] = testMNBSVM(model, D.I(testIdx)', truths, params);
acc = acc(1)/100;
predictions = ~predictions;
truths = ~truths;

[~, precision, recall] = qualityMeasures(truths, predictions);

end

