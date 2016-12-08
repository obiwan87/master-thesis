% Replace all words with its most frequent of k NNs that is more frequent than
% then reference word itself.
p = sequence(fork(nop(), grid('LocalLexicalKnnSubstitution' ,'K', num2cell(5:5:15), 'DictDeltaTresh', {10}, 'MaxIter', {100})), WordCountMatrix(), SVMClassifier('SVMParams', {'Holdout', 0.8}));
P = pipeline(p);

r = ExperimentReport(4, 'erweiterung', 'Local Lexical Substitution', '');
figure; plot(P);
P.execute(W, r)