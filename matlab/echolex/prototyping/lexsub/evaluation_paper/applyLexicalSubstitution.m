function [trainingSubstitutionMap, oovSubstitutionMap] = applyLexicalSubstitution(trainingSet, a, b, c, testSet, d)

scoreFunction = @bayes_hypothesis_probability;
q1 = trainingSet.ViCount >= 1 & trainingSet.B==1;

trainingSetWords = trainingSet.V(q1);
trainingSetFreqs = trainingSet.F(q1, :);
maxClusters = round(c.*numel(trainingSetWords));

dists = ngrams_pdist(trainingSet.m, trainingSetWords, 1);
likelihoods = binomial_likelihood_ratio(trainingSetFreqs);
clusters = pairwise_clustering(dists, likelihoods, 'Linkage', 'complete', ...
    'MaxClust', maxClusters, 'ScoreFunction', scoreFunction, ...
    'ScoreFunctionParameter1', a, ...
    'ScoreFunctionParameter2', b);

[trainingSubstitutionMap, clusterWordMap] = apply_cluster_substitutions2(trainingSetFreqs, clusters);

%% Deal with OOV words
oovSubstitutionMap = containers.Map();
if d > 0
    f = @(x) min(x,[],2);
    trainingSetWords = trainingSet.V(q1);
    
    q2 = testSet.ViCount >= 1 & testSet.B == 1;
    testSetWords = testSet.V(q2);
    
    unknownWords = setdiff(testSetWords, trainingSetWords);
    distsUnknownWords = ngrams_pdist2(trainingSet.m, unknownWords, trainingSetWords, 1);
    C = unique(clusters);
    cluster_dists = zeros(numel(unknownWords), numel(C));
    
    for i=1:numel(C)
        b = clusters == C(i);
        cluster_dists(:,i) = f(distsUnknownWords(:,b));
    end
    
    [dist, nns] = sort(cluster_dists, 2, 'ascend');    
    clusterAssignmentMap = containers.Map();
    for i=1:size(nns,1)
        if dist(i,1) <= d
            oovSubstitutionMap(unknownWords{i}) = clusterWordMap{nns(i,1)};
            clusterAssignmentMap(unknownWords{i}) = nns(i,1);
        end
    end
end
end

