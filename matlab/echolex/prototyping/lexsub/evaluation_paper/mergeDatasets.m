function [mergedDataset, trainInd, testInd] = mergeDatasets(trainingSet,testSet)

T = [trainingSet.T; testSet.T];
Y = [trainingSet.Y; testSet.Y];
mergedDataset = io.DocumentSet(T, Y); 
mergedDataset.wordCountMatrix();

trainInd = 1:numel(trainingSet.T);
testInd = (1:numel(testSet.T)) + numel(trainInd);

end

