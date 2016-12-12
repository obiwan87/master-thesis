accuracies = zeros(numel(Ws),1);
for j = 1:numel(Ws)
    D = Ws{j};
    c = cvpartition(D.Y, 'Kfold', 2);
    predictions = zeros(size(D.Y));
    wordCountMatrix = D.wordCountMatrix();
    classes = unique(D.Y);
    
    for k=1:c.NumTestSets
        cL = zeros(numel(D.V), numel(classes));
        % Indices for training set
        trainingIdx = training(c, k);                
        testIdx = find(test(c, k));
        
        % Find words the training set doesn't have
        wordCountMatrixTraining = wordCountMatrix(trainingIdx, :);
        w = find(sum(wordCountMatrixTraining) > 0);
        for i=1:numel(classes)
            cl = classes(i);
            samples = D.Y(trainingIdx) == cl;
            cw = sum(wordCountMatrixTraining(samples,:)) > 0;
            cL(cw,i) = 1;
        end
        
        for i=1:numel(testIdx)            
            idx = testIdx(i);
            ii = intersect(D.I{idx}, w);
            predictions(idx) = classes(maxi(sum(cL(ii,:))));
        end

    end
    accuracies(j) = sum(predictions == D.Y) / numel(D.Y);
end