function [ acc ] = trainTestNBSVM( D, trainingIdx, testIdx, p)

if nargin < 4
    p = 0;
end
params = struct('dictsize', numel(D.V), 'trainp', p, 'testp', p, 'C', 1);
model = trainMNBSVM(D.I(trainingIdx)',~D.Y(trainingIdx)', params);
acc = testMNBSVM(model, D.I(testIdx)',~D.Y(testIdx)', params);
acc = acc(1)/100;

end

