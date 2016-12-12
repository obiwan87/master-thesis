experiment_id = 6;
name = 'Lexical Graph Substitution';
description = 'Compare LLKS/GLKS with Graph substitution approaches';

crossvalParams = allcomb({'holdout'}, num2cell([0.5:0.1:0.9 0.95]));
crossvalParams = arrayfun(@(x) {crossvalParams{x,1}, crossvalParams{x,2}}, 1:size(crossvalParams,1), 'UniformOutput', false);
datasets = 1:3;
p = sequence( ... 
      fork(nop(), ...
           pgrid('LocalLexicalKnnSubstitution', 'K', 5), ...
           pgrid('GACLexicalSubstitution', 'GroupNumber', 1000, 'K', 5)), ...
      fork(sequence(TfIdf(), fork(pgrid('SVMClassifier', 'CrossvalParams', crossvalParams, 'Repeat', 15)))));

h = figure; plot(pipeline(p));
waitforbuttonpress
close(h);
for i=datasets
    W = Ws{i};
    dataset = business_signals{i};
   
    report = ExperimentReport(experiment_id, dataset, name, description);
    P = pipeline(p);
    
    P.execute(W, report);
    store.add(report);
end