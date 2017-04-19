W = Ws{2};
%EW = W.filter_vocabulary(2,Inf,Inf);
EW = W;
% EW.prepare();
% EW.findBigrams();
%EW.prepare();
% bigramFinder = BigramFinder.fromDocumentSet(EW);
%scores = bigramFinder.ngramsScores('raw_freq');
%bEW = bigramFinder.generateNgramsDocumentSet('raw_freq', 2000);

results_fields = ...
    {'holdout', ...
     'cutoff', ...
     'a', ...
     'b', ...
     'max_distance', ...
     'voc_size_orig', ...
     'mean_acc_orig', ...
     'std_acc_orig', ...
     'mean_posterior_orig', ...     
     'voc_size_sub', ...
     'mean_acc_sub', ...
     'std_acc_sub', ...
     'mean_posterior_sub'};

holdout = 0.1;
runs = 10;

cutoffs = 0.3;
as = 0.3:0.1:0.6;
maxDistances = 0.3:0.1:0.5;

param_combinations = allcomb(cutoffs, as, maxDistances);

results = cell(size(param_combinations,1), numel(results_fields));

% Word count matrix
WC = EW.wordCountMatrix();
WC(WC>1) = 1;

% Random Generator State
curr = rng;

for lj=1:numel(holdout)
    %accuracies = zeros(size(param_combinations,1), runs,4);
     
    p1 = zeros(runs,1);
    accuracies1 = zeros(runs,1);    
    vocSizeOrigs = zeros(runs,1);
    rng(curr)
    
    for i = 1:runs
        c = cvpartition(EW.Y, 'holdout', holdout(lj));
        tic
        [trD, teD] = EW.split(c);
        toc
        
        vocSizeOrigs(i) = numel(trD.V);
        
        % Original model        
        nbmodel1 = fitcnb(WC(training(c),:), EW.Y(training(c)),'distribution', 'mn');
        [predictions1, posteriors1] = predict(nbmodel1, WC(test(c),:));
        
        ii1 = sub2ind(size(posteriors1), 1:size(posteriors1,1), (EW.Y(test(c))+1)');
        p1(i) = mean(posteriors1(ii1));
        
        acc1 = sum(predictions1 == EW.Y(test(c))) / numel(predictions1);
        
        accuracies1(i) = acc1;
    end
    
    for li = 1:size(param_combinations,1)
        vocSizeSubs = zeros(runs,1);
        cutoff = param_combinations(li,1);
        a = param_combinations(li,2);
        b = 1 - a;
        maxDistance = param_combinations(li,3);
        
        accuracy1 = 0;
        accuracy2 = 0;
        
        accuracies2 = zeros(runs,1);
        p2 = zeros(runs,1);
        
        rng(curr)
        for i=1:runs
            c = cvpartition(EW.Y, 'holdout', holdout(lj));
            tic
            [trD, teD] = EW.split(c);
            toc
            
            % Create substitution model
            tic
            clusters = pairwise_clustering(trD, 'Linkage', 'complete', 'Cutoff', cutoff, 'ScoreFunctionParam1', a, 'ScoreFunctionParam2', b);
            toc
            
            % Get new training model
            [substitutionMap1, clusterWordMap, clusterWordMapVi] = apply_cluster_substitutions(trD, clusters);
            sTrD = trD.applySubstitution(substitutionMap1);
            
            vocSizeSubs(i) = numel(sTrD.V);
            
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
            sD = io.DocumentSet(sT, sY);
            sWC = sD.wordCountMatrix();
            sWC(sWC>1) = 1;
            toc
            
            nbmodel2 = fitcnb(sWC(training(c),:), sD.Y(training(c)),'distribution', 'mn');
            [predictions2, posteriors2] = predict(nbmodel2, sWC(test(c),:));
            acc1 = accuracies1(i);
            
            acc1             % Just for debugging purposes
            
            acc2 = sum(predictions2 == sD.Y(test(c))) / numel(predictions2)            
            accuracies2(i) = acc2;
            
            ii2 = sub2ind(size(posteriors2), 1:size(posteriors2,1), (sD.Y(test(c))+1)');
            p2(i) = mean(posteriors2(ii2));
            
        end
        results(li,:) = ...
            {holdout(lj), ...
             cutoff, ... 
             a, ...
             b, ...
             maxDistance, ...
             mean(vocSizeOrigs), ...
             mean(accuracies1), ...
             std(accuracies1), ...
             mean(p1), ...
             mean(vocSizeSubs), ...
             mean(accuracies2), ...
             std(accuracies2), ...
             mean(p2)};
        
    end
    
end
results_t = cell2table(results, 'VariableNames', results_fields);