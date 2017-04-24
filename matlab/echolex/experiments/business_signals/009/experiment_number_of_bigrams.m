
experiment_id = 9;
experiment_name = 'Classification accuracy with varying number of bigrams';
experiment_description = 'Use N-Best bigrams';

datasets = 1:2;

P = sequence(fork(nop(), pgrid('NGrams', 'NBest',  [10:10:90 100:100:1000], 'KeepUnigrams', {true, false}, 'ScoreFcn', {'student_t', 'raw_freq'})), ... % Bigram Extraction
             WordCountMatrix(), ... % Feature Extractiob
             fork(SVMClassifier('CrossvalParams', {'kfold', 10}), NaiveBayesClassifier('CrossvalParams', {'Kfold', 10}))); % Evaluation

p = pipeline(P);
figure; plot(p);
waitforbuttonpress
close(gcf);

for i=datasets

% Dataset name
dataset = business_signals{i};
report = ExperimentReport(experiment_id, dataset, experiment_name, experiment_description);

W = Ws2{i};
execute(p, W, report);
store.add(report);

end