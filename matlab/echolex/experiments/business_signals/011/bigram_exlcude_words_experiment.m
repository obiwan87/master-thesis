experiment_id = 11; 
experiment_name = 'Exclude Words  + Bigrams';
experiment_description = 'Test classification accuracy with bigram generation upon excluding words';

% Generate some holdout variations
crossvalParams = allcomb({'holdout'}, num2cell(0.1:0.1:0.9));
crossvalParams = arrayfun(@(x) {crossvalParams{x,1}, crossvalParams{x,2}}, 1:size(crossvalParams,1), 'UniformOutput', false);

p = sequence(fork(pgrid('ExcludeWords', 'MinCount', 2, 'MaxCount', Inf)), ...
             fork(pgrid('NGrams', 'NBest', 120:20:300, 'ScoreFcn', {'raw_freq'})), ...
             WordCountMatrix(), ...
             fork(pgrid('NaiveBayesClassifier', 'CrossvalParams', crossvalParams, 'Repeat', 10))); 
P = pipeline(p);

%figure; plot(P);
%waitforbuttonpress;
close(gcf)
datasets = 1:2;
for dataset=datasets    
    W = Ws{dataset};
    report = ExperimentReport(experiment_id, business_signals{dataset}, experiment_name, experiment_description);
    execute(P,W,report);
    store.add(report);
end