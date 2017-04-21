function [ acc ] = trainTestNBSVM( EW, trainingIdx, testIdx)

params = struct('dictsize', numel(EW.V), 'trainp', 0, 'testp', 0, 'C', 1);
model = trainMNBSVM(EW.I(trainingIdx)',~EW.Y(trainingIdx)', params);
acc = testMNBSVM(model, EW.I(testIdx)',~EW.Y(testIdx)', params);
acc = acc(1)/100;

end

