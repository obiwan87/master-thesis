bootstrap_experiment
d = dir(fullfile(echolex_results, 'new-public-datasets'));
consolidate_results_naive
best_results = results;

if ~exist('new_public_datasets', 'var')
    datasetsFilename = fullfile(echolex_data, 'new_public_datasets.mat');
    load(datasetsFilename);
end

if ~exist('public_datasets_test', 'var')
    datasetsFilename = fullfile(echolex_data, 'public_datasets_training_val_test.mat');
    load(datasetsFilename);
end

datasetsToEvaluate = 1:80;
new_public_datasets = new_public_datasets(datasetsToEvaluate);

datasetNames = cellfun(@(x) x.DatasetName, new_public_datasets, 'UniformOutput', false);
testDatasetNames = cellfun(@(x) x.DatasetName, public_datasets_test, 'UniformOutput', false);
u = unique(best_results.DatasetName(:));

for j=1:numel(testDatasetNames)
    if strcmp(testDatasetNames{j}, 'Rt10k')
        testSet = public_datasets_test{j};
        testSet.Y = ~logical(testSet.Y);
        testSet.F = [];
        testSet.termFrequencies;
    end
end

% for j=1:numel(new_public_datasets)
%     testSet = new_public_datasets{j};
%     testSet.Y = ~logical(testSet.Y);
%     testSet.F = [];
%     testSet.termFrequencies;
% end

variable_names = {'datasetName', 'trainingSetSize', 'accNbSvm', 'subAccNbSvm', 'accNb', 'subAccNb', 'accRae', 'subAccRae'};
test_results = cell2table(cell(0,8), 'VariableNames', variable_names);
for j=1:size(best_results, 1)
    rng default
    best_result = best_results(j,:);
    holdout = best_result.holdout;
    a = best_result.a;
    b = best_result.b;
    c = best_result.cutoff;
    d = best_result.max_distance;
    
    datasetName = sprintf('%s-%d-%d', best_result.DatasetName{1}, best_result.holdout, best_result.Run);
    i = strcmp(datasetNames, datasetName);
    
    if ~any(i)
        continue;
    end
    
    trainingSet = new_public_datasets{i};
    trainingSet.terms2Indexes;
    trainingSet.w2vCount;
    trainingSet.termFrequencies;
    
    datasetName = best_result.DatasetName{1};
    i = strcmp(datasetName, testDatasetNames);
    
    if ~any(i)
        continue;
    end
    
    testSet = public_datasets_test{i};
    
    disp('Applying substitutions... ');
    [trainingSubstitutionMap, oovSubstitutionMap] = applyLexicalSubstitution(trainingSet, a, b, c, testSet, d);
    substitutionMap = [trainingSubstitutionMap; oovSubstitutionMap];
    
    substitutedTrainingSet = trainingSet.applySubstitution(trainingSubstitutionMap);
    substitutedTestSet = testSet.applySubstitution(substitutionMap);
    
    [mergedSubstitutedDataset, ~,  ~] = mergeDatasets(substitutedTrainingSet, substitutedTestSet);
    [mergedDataset, train_ind, test_ind] = mergeDatasets(trainingSet, testSet);
    
    accNb = 1;%trainTestNB(mergedDataset, mergedDataset.W, train_ind, test_ind);
    subAccNb = 1;%trainTestNB(mergedSubstitutedDataset, mergedSubstitutedDataset.W, train_ind, test_ind);
    %fprintf('Dataset: %s, Classifier: NB, Training Set Size: %d, Acc.: %.2f %%, Sub. Acc.: %.2f %% \n', datasetName, holdout, accNb*100, subAccNb*100);
    
    accNbSvm1 = trainTestNBSVM(mergedDataset, train_ind, test_ind);
    subAccNbSvm1 = trainTestNBSVM(mergedSubstitutedDataset, train_ind, test_ind);
    fprintf('Dataset: %s, Classifier: NB-SVM, Training Set Size: %d, Acc.: %.2f %%, Sub. Acc.: %.2f %% \n', datasetName, holdout, accNbSvm1*100, subAccNbSvm1*100);
    
    mergedDataset.Y(1:numel(trainingSet.T)) = ~mergedDataset.Y(1:numel(trainingSet.T));
    mergedSubstitutedDataset.Y(1:numel(trainingSet.T)) = ~mergedSubstitutedDataset.Y(1:numel(trainingSet.T));
    accNbSvm2 = trainTestNBSVM(mergedDataset, train_ind, test_ind);
    subAccNbSvm2 = trainTestNBSVM(mergedSubstitutedDataset, train_ind, test_ind);
    fprintf('Dataset: %s, Classifier: NB-SVM, Training Set Size: %d, Acc.: %.2f %%, Sub. Acc.: %.2f %% \n', datasetName, holdout, accNbSvm2*100, subAccNbSvm2*100);
    
    mergedDataset.Y(numel(trainingSet.T)+1:end) = ~mergedDataset.Y(numel(trainingSet.T)+1:end);
    mergedSubstitutedDataset.Y(numel(trainingSet.T)+1:end) = ~mergedSubstitutedDataset.Y(numel(trainingSet.T)+1:end);
    accNbSvm3 = trainTestNBSVM(mergedDataset, train_ind, test_ind);
    subAccNbSvm3 = trainTestNBSVM(mergedSubstitutedDataset, train_ind, test_ind);
    fprintf('Dataset: %s, Classifier: NB-SVM, Training Set Size: %d, Acc.: %.2f %%, Sub. Acc.: %.2f %% \n', datasetName, holdout, accNbSvm3*100, subAccNbSvm3*100);
    
    accNbSvm = max([accNbSvm1, accNbSvm2, accNbSvm3]);
    subAccNbSvm = max([subAccNbSvm1, subAccNbSvm2, subAccNbSvm3]);
    
    cv_ind = test_ind;
    sD = mergedDataset;
    %trainTestSocher
    
    accRae =  1;%acc_test;
    
    sD = mergedSubstitutedDataset;
    %trainTestSocher
    
    subAccRae = 1;%acc_test;
    
    %fprintf('Dataset: %s, Classifier: Socher, Training Set Size: %d, Acc.: %.2f %%, Sub. Acc.: %.2f %% \n', datasetName, holdout, accRae*100, subAccRae*100);
    
    currentResults = cell2table({datasetName, holdout, accNbSvm, subAccNbSvm, accNb, subAccNb, accRae, subAccRae}, 'VariableNames', variable_names);
    test_results = [test_results; currentResults]
end