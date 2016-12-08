experiment_id = 5;
name = 'LLKS with common words of class';
description = '';
dataset = 'fuehrungswechsel';
W = Ws{strcmp(dataset, business_signals)};

p = sequence(fork(nop(), sequence(nop(), pgrid('LocalLexicalKnnSubstitution', 'K', 10:5:20), CommonClassWords())) , TfIdf(), SVMClassifier('SVMParams', {'kfold', 5}));
P = pipeline(p);
scheme = ReportScheme({'LocalLexicalKnnSubstitution', 'CommonClassWords'}, ... 
                      {'LVi', 'info.LVi', ...
                       'vocSizeBefore', 'info.vocSizeBefore', ...
                       'vocSizeAfter', 'info.vocSizeAfter', ...
                       'remainingWords', 'info.remainingWords', ...
                       'excludedWords', 'info.excludedWords'
                       });
                   
report = ExperimentReport(experiment_id,dataset, name, description, scheme);

P.execute(W,report);

store.add(report);