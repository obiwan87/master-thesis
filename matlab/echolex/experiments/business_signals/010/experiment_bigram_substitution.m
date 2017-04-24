% Set up experiment in which there is varying size of training set and
% varying numbers of bigrams with and without lexical substitution

experiment_id = 103;
experiment_name = 'LexSub with Bigrams';
experiment_description = 'Analyze lexical substitution in combination with unigrams + bigrams';

% Generate some holdout variations
crossvalParams = allcomb({'holdout'}, num2cell(0.1:0.1:0.9));
crossvalParams = arrayfun(@(x) {crossvalParams{x,1}, crossvalParams{x,2}}, 1:size(crossvalParams,1), 'UniformOutput', false);

% We may need percetual group number
p = sequence(ExcludeWords('MinCount', 2, 'MaxCount', Inf), ...
    LocalLexicalKnnSubstitution('K', 5), ...
    fork(pgrid('NGrams', 'NBest', 0:20:300, 'ScoreFcn', {'raw_freq'})), WordCountMatrix('Binary', true), ... 
    fork(pgrid('NaiveBayesClassifier', 'CrossvalParams', crossvalParams, 'Repeat', 10)));
%
P = pipeline(p);

% Visualize before starting
figure; plot(P);
waitforbuttonpress
close(gcf);

datasets = 2;
for dataset=datasets    
    W = Ws{dataset};
    report = ExperimentReport(experiment_id, business_signals{dataset}, experiment_name, experiment_description);
    execute(P,W,report);
    store.add(report);
end