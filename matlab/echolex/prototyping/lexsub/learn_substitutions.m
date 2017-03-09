% Learn substitutions with regression method

W = Ws{1};

% Create a multinomial BOW Naive-Bayes model
rng default
c = cvpartition(W.Y, 'holdout', 0.5);

[e1, P1, acc1, model1] = modelQuality(W.wordCountMatrix(), W.Y, c);

mean(e1)

args = struct('DocumentSet', W);
lexsub = GraphLexicalSubstitution('K', 3, 'SubstitutionThr', 15);

out = lexsub.doExecute([], args);
data = out.Out.wordCountMatrix();
labels = out.Out.Y;
[e2, P2, acc2, model2] = modelQuality(data, W.Y, c);

mean(e2)