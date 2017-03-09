p = sequence(WordCountMatrix(), NaiveBayesClassifier('CrossvalParams', {'kfold', 10}));
P = pipeline(p);

execute(P, W);