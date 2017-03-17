% Learn substitutions with regression method

W = Ws{2};
% Create a multinomial BOW Naive-Bayes model
rng default

EW = W.filter_vocabulary(2,Inf,Inf);

bigramFinder = BigramFinder.fromDocumentSet(EW);
[~,r1] = bigramFinder.nbest('raw_freq', 100)

c = cvpartition(EW.Y, 'holdout', 0.1);
PW = io.Word2VecDocumentSet(m,EW.T(test(c)),EW.Y(test(c)));

args = struct('DocumentSet', PW);
lexsub = ProbabilisticLexicalSubstitution('K', 5, 'MaxIter', 1, 'SubstitutionThr', 15, 'MinSimilarity', 0.5);
out = lexsub.doExecute([], args);
LW = out.Out;

bigramFinder = BigramFinder.fromDocumentSet(LW);
[~,r2] = bigramFinder.nbest('raw_freq', 100)