% Set up experiment in which there is varying size of training set and
% varying numbers of bigrams with and without lexical substitution

experiment_id = 10;
experiment_name = 'LexSub with Bigrams';
experiment_description = 'Analyze lexical substitution in combination with unigrams + bigrams';

% Generate some holdout variations
crossvalParams = allcomb({'holdout'}, num2cell(0.1:0.1:0.9));
crossvalParams = arrayfun(@(x) {crossvalParams{x,1}, crossvalParams{x,2}}, 1:size(crossvalParams,1), 'UniformOutput', false);

% We may need percetual group number
p = sequence(fork(nop(), LocalLexicalKnnSubstitution('K', 5)), ...
    fork(pgrid('NGrams', 'NBest', 0:10:80, 'ScoreFcn', {'student_t'})), WordCountMatrix(), fork(pgrid('SVMClassifier', 'CrossvalParams', crossvalParams, 'Repeat', 10)));
%
P = pipeline(p);

% Visualize before starting
figure; plot(P);
waitforbuttonpress
close(gcf);

datasets = 1:2;
for dataset=datasets    
    W = Ws{dataset};
    report = ExperimentReport(experiment_id, business_signals{dataset}, experiment_name, experiment_description);
    execute(P,W,report);
    store.add(report);
end