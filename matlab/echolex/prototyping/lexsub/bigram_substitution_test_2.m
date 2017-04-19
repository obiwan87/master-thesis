EW = W;
bigramsEW = bigramsW;

results_fields = ...
    {'holdout', ...
    'cutoff', ...
    'a', ...
    'b', ...
    'max_distance', ...
    'voc_size_orig_uni', ...
    'mean_acc_orig_uni', ...
    'std_acc_orig_uni', ...
    'mean_posterior_orig_uni', ...
    'voc_size_orig_bi', ...
    'mean_acc_orig_bi', ...
    'std_acc_orig_bi', ...
    'mean_posterior_orig_bi', ...
    'voc_size_sub_uni', ...
    'mean_acc_sub_uni', ...
    'std_acc_sub_uni', ...
    'mean_posterior_sub_uni', ...
    'voc_size_sub_bi', ...
    'mean_acc_sub_bi', ...
    'std_acc_sub_bi', ...
    'mean_posterior_sub_bi'};

useGpu = false;
folds = 3;

cutoffs = 0.3;
as = 0.5;
maxDistances = 1;

param_combinations = allcomb(cutoffs, as, maxDistances);

all_results = cell(numel(folds),1);

% Word count matrix
unigramsWC = EW.W;
unigramsWC(unigramsWC>1) = 1;

bigramsWC = bigramsEW.W;
bigramsWC(bigramsWC>1) = 1;

% Random Generator State
curr = rng;

for lj=1:numel(folds)
    %accuracies = zeros(size(param_combinations,1), runs,4);
    results = cell(size(param_combinations,1), numel(results_fields));
    
    fold = folds(lj);
    abs_fold = abs(fold);
    
    p1_uni = zeros(abs_fold,1);
    p1_bi = zeros(abs_fold,1);
    
    accuracies1_uni = zeros(abs_fold,1);
    accuracies1_bi = zeros(abs_fold,1);
    
    vocSizeOrigs_uni = zeros(abs_fold,1);
    vocSizeOrigs_bi = zeros(abs_fold,1);
    
    
    % Store results here
    accuracies2_uni = zeros(abs_fold, size(param_combinations,1));
    accuracies2_bi =  zeros(abs_fold, size(param_combinations,1));
    
    vocSizeSubs_uni = zeros(abs_fold, size(param_combinations,1));
    vocSizeSubs_bi =  zeros(abs_fold, size(param_combinations,1));
    
    p2_uni = zeros(abs_fold,size(param_combinations,1));
    p2_bi = zeros(abs_fold,size(param_combinations,1));
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    rng(curr)
    c = cvpartition(EW.Y, 'kfold', abs(fold));
    for i = 1:abs(fold)
        fprintf('Fold %d/%d \n', i, abs(fold));
        
        %% Common Stuff
        if sign(fold) < 0
            trainingIdx = test(c,i);
            testIdx = training(c,i);
        else
            trainingIdx = training(c,i);
            testIdx = test(c,i);
        end
        
        tic
        [trD_uni, teD_uni] =        EW.split(testIdx, trainingIdx);
        [trD_bi,  teD_bi ] = bigramsEW.split(testIdx, trainingIdx);
        toc
        
        vocSizeOrigs_uni(i) = numel(EW.V);
        vocSizeOrigs_bi(i)  = numel(bigramsEW.V);
        
        %% Original Documents 
        
        % Unigrams
        nbmodel1_uni = fitcnb(unigramsWC(trainingIdx,:), EW.Y(trainingIdx),'distribution', 'mn');
        [predictions1_uni, posteriors1_uni] = predict(nbmodel1_uni, unigramsWC(testIdx,:));
        
        ii1 = sub2ind(size(posteriors1_uni), 1:size(posteriors1_uni,1), (EW.Y(testIdx)+1)');
        p1_uni(i) = mean(posteriors1_uni(ii1));
        
        acc1_uni = sum(predictions1_uni == EW.Y(testIdx)) / numel(predictions1_uni);
        
        accuracies1_uni(i) = acc1_uni;
        
        % Bigrams
        nbmodel1_bi = fitcnb(bigramsWC(trainingIdx,:), bigramsEW.Y(trainingIdx),'distribution', 'mn');
        [predictions1_bi, posteriors1_bi] = predict(nbmodel1_bi, bigramsWC(testIdx,:));
        
        ii1 = sub2ind(size(posteriors1_bi), 1:size(posteriors1_bi,1), (bigramsEW.Y(testIdx)+1)');
        p1_bi(i) = mean(posteriors1_bi(ii1));
        
        acc1_bi = sum(predictions1_bi == bigramsEW.Y(testIdx)) / numel(predictions1_bi);
        
        accuracies1_bi(i) = acc1_bi;
        
        %% Substitutions 
        [dist_u, pL_] = calculate_unigrams_distances(trD_uni);
        
        for li = 1:size(param_combinations,1)
            fprintf('Fold: %d/%d, Parameter Combination: %d/%d \n \n', i, abs(fold), li, size(param_combinations,1));
            current_params = num2cell(param_combinations(li,:));
            fprintf('cutoff: %.2f, a: %.2f, maxDistance: %.2f\n \n', current_params{:});
            
            cutoff = param_combinations(li,1);
            a = param_combinations(li,2);
            b = 1 - a;
            maxDistance = param_combinations(li,3);
            
            % Create substitution model
            tic
            clusters = pairwise_clustering(dist_u, pL_, 'Linkage', 'complete', 'Cutoff', cutoff, 'ScoreFunctionParam1', a, 'ScoreFunctionParam2', b);
            toc
            
            % Get new training model
            [substitutionMap1, clusterWordMap, clusterWordMapVi] = apply_cluster_substitutions(trD_uni, clusters);
            sTrD = trD_uni.applySubstitution(substitutionMap1);
            
            % Map unseen words to clostest cluster
            substitutionMap2 = nearest_cluster_substitution(teD_uni, trD_uni, clusters, clusterWordMapVi, 'Method', 'min', 'MaxDistance', maxDistance);
            
            % Apply both substitutions to test set
            substitutionMap = [substitutionMap1; substitutionMap2];
            sTeD = teD_uni.applySubstitution(substitutionMap);
            
            % Model with substitutions
            tic
            sT = cell(size(EW.T));
            sT(trainingIdx) = sTrD.T;
            sT(testIdx) = sTeD.T;
            sY = zeros(size(EW.Y));
            sY(trainingIdx) = EW.Y(trainingIdx);
            sY(testIdx) = EW.Y(testIdx);
            sD_uni = io.DocumentSet(sT, sY);
            sWC_uni = sD_uni.wordCountMatrix();
            sWC_uni(sWC_uni>1) = 1;
            toc
            
            nbmodel2_uni = fitcnb(sWC_uni(trainingIdx,:), sD_uni.Y(trainingIdx), 'distribution', 'mn');
            [predictions2_uni, posteriors2_uni] = predict(nbmodel2_uni, sWC_uni(testIdx,:));
            
            acc2_uni = sum(predictions2_uni == sD_uni.Y(testIdx)) / numel(predictions2_uni);
            ii2_uni = sub2ind(size(posteriors2_uni), 1:size(posteriors2_uni,1), (sD_uni.Y(testIdx)+1)');
            
            %% Bigrams
            
            sD_bi = BigramFinder.generateAllNGrams(sD_uni,2,true);
            sD_bi.wordCountMatrix();
            
            sWC_bi = sD_bi.W;
            sWC_bi(sWC_bi>1) = 1;
            
            nbmodel2_bi = fitcnb(sWC_bi(trainingIdx,:), sD_bi.Y(trainingIdx), 'distribution', 'mn');
            [predictions2_bi, posteriors2_bi] = predict(nbmodel2_bi, sWC_bi(testIdx,:));
            
            acc2_bi = sum(predictions2_bi == sD_bi.Y(testIdx)) / numel(predictions2_bi);
            ii2_bi = sub2ind(size(posteriors2_bi), 1:size(posteriors2_bi,1), (sD_bi.Y(testIdx)+1)');
            
            %% Gather results
            accuracies2_uni(i,li) = acc2_uni;
            accuracies2_bi(i,li) = acc2_bi;
            
            p2_uni(i, li) = mean(posteriors2_uni(ii2_uni));
            p2_bi(i, li) = mean(posteriors2_bi(ii2_bi));
            
            vocSizeSubs_uni(i,li) = numel(sD_uni.V);
            vocSizeSubs_bi(i,li) = numel(sD_bi.V);
            %%.............................................................
            
            % Show results
            fprintf('Accuracy Unigrams (Orig): %.2f %%\n', acc1_uni*100);
            fprintf('Accuracy Unigrams (Sub): %.2f %%\n', acc2_uni*100);
            
            fprintf('Accuracy Bigrams (Orig): %.2f %%\n', acc1_bi*100);            
            fprintf('Accuracy Bigrams (Sub): %.2f %%\n \n', acc2_bi*100);

        end
    end
    
    %% Save Results
    for li=1:size(param_combinations)
        cutoff = param_combinations(li,1);
        a = param_combinations(li,2);
        b = 1 - a;
        maxDistance = param_combinations(li,3);
        
        results(li,:) = ...
            {folds(lj), ...
            cutoff, ...
            a, ...
            b, ...
            maxDistance, ...
            mean(vocSizeOrigs_uni), ...
            mean(accuracies1_uni), ...
            std(accuracies1_uni), ...
            mean(p1_uni), ...
            mean(vocSizeOrigs_bi), ...
            mean(accuracies1_bi), ...
            std(accuracies1_bi), ...
            mean(p1_bi), ...
            mean(vocSizeSubs_uni(:,li)), ...
            mean(accuracies2_uni(:,li)), ...
            std(accuracies2_uni(:,li)), ...
            mean(p2_uni(:,li)), ...
            mean(vocSizeSubs_bi(:,li)), ...
            mean(accuracies2_bi(:,li)), ...
            std(accuracies2_bi(:,li)), ...
            mean(p2_bi(:,li))};
    end
    
    all_results{lj} = results;
end