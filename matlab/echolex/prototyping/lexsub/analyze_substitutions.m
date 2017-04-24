rng default

W = Ws{1};
partition = cvpartition(W.Y, 'kfold', 5);
lexsub = LocalLexicalKnnSubstitution('K', 5);
for i = 1:partition.NumTestSets
    training_set = training(partition, i);
    pW = io.Word2VecDocumentSet(W.m, W.T(training_set), W.Y(training_set));
    
end