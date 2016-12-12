experiment_id = 7;
name = 'Detect overfitting in TfIdf';
datasets = 1:3;

crossvalparams = allcomb({'kfold'}, num2cell(2:5:22));
crossvalparams = arrayfun(@(x) {crossvalparams{x,1}, crossvalparams{x,2}}, 1:size(crossvalparams,1), 'UniformOutput', false);
p = sequence(...
          fork( ...
                sequence(TfIdf(), fork(pgrid('SVMClassifier', 'SVMParams',  crossvalparams))), ...
                pgrid('NaiveClassifier', 'CrossvalParams', crossvalparams) ...          
             ));

P = pipeline(p);
h = figure; plot(P);
waitforbuttonpress
close (h);

for i=datasets
    dataset = Ws{i};
    report = ExperimentReport(experiment_id, business_signals{i}, name, '');
    
    P.execute(Ws{i},report);
    store.add(report);
end
