experiment_id = 8;
name = 'Test Classification with bigrams';
dataset = 3;
W = Wu;
dataset_name = business_signals{dataset};
p = sequence(NaiveClassifier('CrossvalParams', {'kfold', 20}));
P = pipeline(p);
report = ExperimentReport(experiment_id, dataset_name, name, '');

P.execute(W,report);