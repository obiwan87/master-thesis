experiment_id = 4;
name = 'Overfitting of TfIdf';
description = 'TfIdf maybe not suitable for evaluation purposes. Find out how much overfitting occurs in comparison to word2vec vectors';
dataset = 'fuehrungswechsel';
W = Ws{strcmp(dataset, business_signals)};

report = ExperimentReport(experiment_id, dataset, name, description);

p = sequence(fork(pgrid('ExcludeWords', 'MinCount', 1:5, 'MaxCount', Inf)), fork(TfIdf(), TfIdfVectorizer()), SVMClassifier('SVMParams', {'kfold', 10}));
P = pipeline(p);

P.execute(W, report);
