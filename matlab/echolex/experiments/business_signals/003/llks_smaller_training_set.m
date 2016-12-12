experiment_id = 3;
datasets = find(strcmp('erweiterung', business_signals) | strcmp('fuehrungswechsel', business_signals) |strcmp('fusion', business_signals));
name = 'Test LLKS with smaller training set';
description = 'LLKS and GLKS didn''t improve classification results with "large" training sets. This experiment verifies whether learning with smaller training sets is made more effective with LLKS';

S = {'LocalLexicalKnnSubstitution', {'vocSizeBefore', 'info.vocSizeBefore', 'vocSizeAfter', 'info.vocSizeAfter'}};
scheme = ReportScheme(S{:});
p = sequence(...
        fork(nop(), pgrid('LocalLexicalKnnSubstitution', 'K', 5:5:30, 'MaxIter', 10)), WordCountMatrix(), ... 
        fork(SVMClassifier('CrossvalParams', {'Holdout', 0.7}, 'Repeat', 20),  ...
             SVMClassifier('CrossvalParams', {'Holdout', 0.8}, 'Repeat', 20),  ...
             SVMClassifier('CrossvalParams', {'Holdout', 0.9}, 'Repeat', 20)));

P = pipeline(p);
figure; plot(P);
for i=1:numel(datasets)
    report = ExperimentReport(experiment_id, business_signals{datasets(i)}, name, description, scheme);
    W = Ws{datasets(i)};
    P = pipeline(p);
    execute(P, W, report);
    store.add(report);
    report.Duration
end
