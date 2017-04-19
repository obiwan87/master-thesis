%W = Ws{1};
%W.prepare();
bigramFinder = BigramFinder.fromDocumentSet(W);

substitute_training_set = true;

%scores = bigramFinder.ngramsScores('raw_freq');
EW = bigramFinder.generateNgramsDocumentSet('raw_freq', size(scores,1));
EW.findBigrams();
%EW = bigramFinder.generateNgramsDocumentSet('raw_freq', 1000);
holdout = 0.3;
runs = 10;

cutoffs = 0.9;
as = 0.5;

mergeFunction = @(X) harmmean(X,[],1);
param_combinations = allcomb(cutoffs, as);
%results = cell2table(num2cell(zeros(size(param_combinations,1),8)), 'VariableNames', {'holdout', 'cutoff', 'a', 'b', 'accuracy_orig', 'posterior_orig', 'accuracy_sub' 'posterior_sub'});

% Word count matrix
WC = EW.wordCountMatrix();
WC(WC>1) = 1;

cutoff = 0.45;
a = 0.4;
maxDistance = 0.7;
%curr = rng;
rng(curr);
c = cvpartition(EW.Y, 'holdout', holdout);

[trD, teD] = EW.split(c);

nbmodel1 = fitcnb(WC(training(c),:), EW.Y(training(c)),'distribution', 'mn');
[predictions1, posteriors1] = predict(nbmodel1, WC(test(c),:));

ii1 = sub2ind(size(posteriors1), 1:size(posteriors1,1), (EW.Y(test(c))+1)');
%p1 = p1 + mean(posteriors1(ii1));

acc1 = sum(predictions1 == EW.Y(test(c))) / numel(predictions1)

if substitute_training_set
    clusters = pairwise_clustering_bigrams(trD, 'Cutoff', cutoff, 'Linkage', 'complete', 'ScoreFunctionParam1', a, 'ScoreFunctionParam2', 1-a, 'BigramsPDistParams', {'MaxDistance', 1});
    [substitutionMap1, clusterWordMap] = apply_cluster_substitutions_bigrams(trD, clusters);
    sTrD = trD.applySubstitution(substitutionMap1);
else
    clusters = 1:numel(trD.V);
    clusterWordMap = trD.V;
    clusterWordMapVi = trD.Vi;
    substitutionMap1 = containers.Map();
    sTrD = trD;
end

tic
substitutionMap2 = nearest_cluster_substitution_bigrams(teD, trD, clusters, clusterWordMap, 'Method', 'min', 'MaxDistance', maxDistance);
substitutionMap = [substitutionMap1; substitutionMap2];
sTeD = teD.applySubstitution(substitutionMap);
toc 

tic
sT = cell(size(EW.T));
sT(training(c)) = sTrD.T;
sT(test(c)) = sTeD.T;
sY = zeros(size(EW.Y));
sY(training(c)) = EW.Y(training(c));
sY(test(c)) = EW.Y(test(c));
sD = io.DocumentSet(sT, sY);
sD.prepare();
sWC = sD.W;
sWC(sWC>1) = 1;
toc

nbmodel2 = fitcnb(sWC(training(c),:), sD.Y(training(c)),'distribution', 'mn');
[predictions2, posteriors2] = predict(nbmodel2, sWC(test(c),:));
acc2 = sum(predictions2 == sD.Y(test(c))) / numel(predictions2)
