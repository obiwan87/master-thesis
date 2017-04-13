%W = Ws{2};
%EW = W.filter_vocabulary(2,Inf,Inf);
EW = W;
%EW.prepare();
% bigramFinder = BigramFinder.fromDocumentSet(EW);
%scores = bigramFinder.ngramsScores('raw_freq');
%bEW = bigramFinder.generateNgramsDocumentSet('raw_freq', 2000);

holdout = 0.1;
runs = 10;

cutoffs = 0.2;
as = 0.5;
maxDistance = 0.4;

param_combinations = allcomb(cutoffs, as);
%results = cell2table(num2cell(zeros(size(param_combinations,1),8)), 'VariableNames', {'holdout', 'cutoff', 'a', 'b', 'accuracy_orig', 'posterior_orig', 'accuracy_sub' 'posterior_sub'});

% Word count matrix
WC = EW.wordCountMatrix();
WC(WC>1) = 1;

for lj=1:numel(holdout)
    %accuracies = zeros(size(param_combinations,1), runs,4);
    for li = 1:size(param_combinations,1)
        cutoff = param_combinations(li,1);
        a = param_combinations(li,2);
        b = 1 - a;
        accuracy1 = 0;
        accuracy2 = 0;
        p1 = 0;
        p2 = 0;
        rng default
        
        for i = 1:runs
            c = cvpartition(EW.Y, 'holdout', holdout(lj));
            tic 
            [trD, teD] = EW.split(c);
            toc                                    
            % Original model

            nbmodel1 = fitcnb(WC(training(c),:), EW.Y(training(c)),'distribution', 'mn');
            [predictions1, posteriors1] = predict(nbmodel1, WC(test(c),:));           
            
            ii1 = sub2ind(size(posteriors1), 1:size(posteriors1,1), (EW.Y(test(c))+1)');
            p1 = p1 + mean(posteriors1(ii1));
            
            acc1 = sum(predictions1 == EW.Y(test(c))) / numel(predictions1)            
            
            accuracy1 = accuracy1 + acc1;
            
            % Create substitution model
            tic
            clusters = pairwise_clustering(trD, 'Linkage', 'complete', 'Cutoff', cutoff, 'ScoreFunctionParam1', a, 'ScoreFunctionParam2', b);
            toc
            
            % Get new training model
            [substitutionMap1, clusterWordMap, clusterWordMapVi] = apply_cluster_substitutions(trD, clusters);
            sTrD = trD.applySubstitution(substitutionMap1);
            
            % Map unseen words to clostest cluster
            substitutionMap2 = nearest_cluster_substitution(teD, trD, clusters, clusterWordMapVi, 'Method', 'min', 'MaxDistance', maxDistance);
            
            % Apply both substitutions to test set
            substitutionMap = [substitutionMap1; substitutionMap2];
            sTeD = teD.applySubstitution(substitutionMap);

            
            % Model with substitutions
            tic
            sT = cell(size(EW.T));
            sT(training(c)) = sTrD.T;
            sT(test(c)) = sTeD.T;
            sY = zeros(size(EW.Y));
            sY(training(c)) = EW.Y(training(c));
            sY(test(c)) = EW.Y(test(c));
            sD = io.Word2VecDocumentSet(EW.m, sT, sY);
            sD.prepare();
            sWC = sD.wordCountMatrix();
            sWC(sWC>1) = 1;
            toc
            
            nbmodel2 = fitcnb(sWC(training(c),:), sD.Y(training(c)),'distribution', 'mn');
            [predictions2, posteriors2] = predict(nbmodel2, sWC(test(c),:));
            acc2 = sum(predictions2 == sD.Y(test(c))) / numel(predictions2)
            accuracy2 = accuracy2 + acc2;
            
            ii2 = sub2ind(size(posteriors2), 1:size(posteriors2,1), (sD.Y(test(c))+1)');
            p2 = p2 + mean(posteriors2(ii2));
            
        end
        results = [results; num2cell([holdout(lj) cutoff a b accuracy1/runs p1/runs accuracy2/runs p2/runs])];
    end
    
end