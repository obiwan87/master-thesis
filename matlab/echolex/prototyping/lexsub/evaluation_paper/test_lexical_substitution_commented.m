% Here we load the best parameter results yielded from cross validation
bootstrap_experiment
consolidate_results
best_parameter_combinations

datasetsFilename = fullfile(echolex_data, 'public_datasets_training_val_test.mat');
load(datasetsFilename);

datasetNames = cellfun(@(x) x.DatasetName, public_datasets_training_validation, 'UniformOutput', false);
u = unique(best_results.DatasetName(:));

% Here we just invert the labels (it's for the SVM-Library... not really important)
for j=1:numel(u)
    if ~strcmp(u{j}, 'Rt10k')
        continue;
    end
    i = strcmp(datasetNames, u(j));
    fullTrainingSet = public_datasets_training_validation{i};
    fullTrainingSet.Y = ~logical(fullTrainingSet.Y);
    testSet = public_datasets_test{i};
    testSet.Y = ~logical(testSet.Y);
end

% 5 repetitions as described in the paper
repetitions = 5;

% result logging
variable_names = {'datasetName', 'trainingSetSize', 'accNbSvm', 'subAccNbSvm', 'accNb', 'subAccNb', 'accRae', 'subAccRae'};
test_results = cell2table(cell(0,8), 'VariableNames', variable_names);
% -----------

for j=1:size(best_results, 1)
    rng default
    for k=1:repetitions
        best_result = best_results(j,:);
        holdout = best_result.holdout;

        % Load the best parameters
        a = best_result.a;
        b = best_result.b;
        c = best_result.cutoff;
        d = best_result.max_distance;
        
        datasetName = best_result.DatasetName{1};
        i = strcmp(datasetNames, datasetName);
        
        % This is the full training dataset, for which we want to compute substitutions.
        % Its type is io.Word2VecDocumentSet and is loaded from 'public_datasets_training_val_test.mat' (see above)         
        fullTrainingSet = public_datasets_training_validation{i};
        
        % Here we randomly sample 'holdout' (percent) senteces from the full dataset and will use it as training-dataset
        cv = cvpartition(fullTrainingSet.Y, 'holdout', holdout);
        sampleSlice = cv.test;
        
        % Create a dataset object with the sampled sentences
        disp('Preparing training set holdout...');
        trainingSet = io.Word2VecDocumentSet(fullTrainingSet.m, fullTrainingSet.T(sampleSlice), fullTrainingSet.Y(sampleSlice));
        trainingSet.terms2Indexes();
        trainingSet.w2vCount();
        trainingSet.termFrequencies();

        % The test-set was held out beforehand and here we store it in the variable testSet
        % The variable public_datasets_test als comes from 'public_datasets_training_val_test.mat'
        testSet = public_datasets_test{i};       
        
        % Apply lexical substitution takes care of everything. The input are the paraemters a,b,c,d the trainingSet and the testSet.
        % The function will return Map-containers (see https://de.mathworks.com/help/matlab/map-containers.html), that represent
        % the substiutions. 
        disp('Applying substitutions... ');
        [trainingSubstitutionMap, oovSubstitutionMap] = applyLexicalSubstitution(trainingSet, a, b, c, testSet, d);
        substitutionMap = [trainingSubstitutionMap; oovSubstitutionMap];
        
        % Here we apply the substiutions to the datasets

        % For the training set we use the trainingSubstiutionMap
        substitutedTrainingSet = trainingSet.applySubstitution(trainingSubstitutionMap);

        % For the test set we want to use the full substiution map (trainingSubstitution + oovSubstitutionMap). They are merge into 
        % 'substitutionMap' on line 71.
        substitutedTestSet = testSet.applySubstitution(substitutionMap);
        
        % From here on it's just training the classification models
        [mergedSubstitutedDataset, ~,  ~] = mergeDatasets(substitutedTrainingSet, substitutedTestSet);
        [mergedDataset, train_ind, test_ind] = mergeDatasets(trainingSet, testSet);
        
        accNbSvm = trainTestNBSVM(mergedDataset, train_ind, test_ind);    
        accNb = trainTestNB(mergedDataset, mergedDataset.W, train_ind, test_ind);
        subAccNb = trainTestNB(mergedSubstitutedDataset, mergedSubstitutedDataset.W, train_ind, test_ind);
        fprintf('Dataset: %s, Classifier: NB, Training Set Size: %d, Acc.: %.2f %%, Sub. Acc.: %.2f %% \n', datasetName, holdout, accNb*100, subAccNb*100);
        
        
        subAccNbSvm = trainTestNBSVM(mergedSubstitutedDataset, train_ind, test_ind);
        fprintf('Dataset: %s, Classifier: NB-SVM, Training Set Size: %d, Acc.: %.2f %%, Sub. Acc.: %.2f %% \n', datasetName, holdout, accNbSvm*100, subAccNbSvm*100);
        
        cv_ind = test_ind;
        sD = mergedDataset;
        trainTestSocher
        
        accRae = acc_test;
        
        sD = mergedSubstitutedDataset;
        trainTestSocher
        
        subAccRae = acc_test;
        
        fprintf('Dataset: %s, Classifier: Socher, Training Set Size: %d, Acc.: %.2f %%, Sub. Acc.: %.2f %% \n', datasetName, holdout, accRae*100, subAccRae*100);
        
        currentResults = cell2table({datasetName, holdout, accNbSvm, subAccNbSvm, accNb, subAccNb, accRae, subAccRae}, 'VariableNames', variable_names);
        test_results = [test_results; currentResults]
    end
end