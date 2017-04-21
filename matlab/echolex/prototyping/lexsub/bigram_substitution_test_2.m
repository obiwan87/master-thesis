for lk = 1:7
    
    EW = Ws{lk};
    bigramsEW = bigramsWs{lk};
    
    results_fields = ...
        {'holdout', ...
        'cutoff', ...
        'a', ...
        'b', ...
        'max_distance', ...
        'linkage', ...
        'voc_size_orig_uni', ...
        'mean_acc_orig_uni_nb', ...
        'std_acc_orig_uni_nb', ...
        'mean_posterior_orig_uni_nb', ...
        'mean_acc_orig_uni_svm', ...
        'std_acc_orig_uni_svm', ...
        'voc_size_orig_bi', ...
        'mean_acc_orig_bi_nb', ...
        'std_acc_orig_bi_nb', ...
        'mean_posterior_orig_bi_nb', ...
        'mean_acc_orig_bi_svm', ...
        'std_acc_orig_bi_svm', ...
        'voc_size_sub_uni', ...
        'mean_acc_sub_uni_nb', ...
        'std_acc_sub_uni_nb', ...
        'mean_posterior_sub_uni_nb', ...
        'mean_acc_sub_uni_svm', ...
        'std_acc_sub_uni_svm', ...
        'voc_size_sub_bi', ...
        'mean_acc_sub_bi_nb', ...
        'std_acc_sub_bi_nb', ...
        'mean_posterior_sub_bi_nb',...
        'mean_acc_sub_bi_svm', ...
        'std_acc_sub_bi_svm'};
    
    useGpu = false;
    folds = [-10 -5 -3 2 3 5 10];
    
    cutoffs = [0.3 0.4 0.5];
    as = [0 0.1 0.2 0.3];
    maxDistances = [0.4 0.5 0.6];
    linkages = {'complete'};
    methodNearestClusterAssignment = 'min';
    
    param_combinations = allcomb(num2cell(cutoffs), num2cell(as), num2cell(maxDistances), num2cell(linkages));
    
    all_results = cell(numel(folds),1);
    
    % Word count matrix
    unigramsWC = EW.W;
    unigramsWC(unigramsWC>1) = 1;
    
    bigramsWC = bigramsEW.W;
    bigramsWC(bigramsWC>1) = 1;
    
    % Random Generator State
    rng default
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
        accuracies1_uni_svm = zeros(abs_fold,1);
        accuracies1_bi_svm = zeros(abs_fold,1);
        
        vocSizeOrigs_uni = zeros(abs_fold,1);
        vocSizeOrigs_bi = zeros(abs_fold,1);
        
        
        % Store results here
        accuracies2_uni = zeros(abs_fold, size(param_combinations,1));
        accuracies2_bi =  zeros(abs_fold, size(param_combinations,1));
        accuracies2_uni_svm = zeros(abs_fold, size(param_combinations,1));
        accuracies2_bi_svm =  zeros(abs_fold, size(param_combinations,1));
        
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
            
            [trD_uni, teD_uni] =        EW.split(testIdx, trainingIdx);
            [trD_bi,  teD_bi ] = bigramsEW.split(testIdx, trainingIdx);
           
            vocSizeOrigs_uni(i) = numel(EW.V);
            vocSizeOrigs_bi(i)  = numel(bigramsEW.V);
            
            %% Original Documents
            
            % Unigrams
            
            [acc1_uni, p_uni] = trainTestNB(EW, unigramsWC, trainingIdx, testIdx);
            [acc1_bi, p_bi] = trainTestNB(bigramsEW, bigramsWC, trainingIdx, testIdx);
            
            % Bigrams
            p1_uni(i) = p_uni;
            p1_bi(i) = p_bi;
            
            acc1_uni_svm = trainTestNBSVM(EW, trainingIdx, testIdx);
            acc1_bi_svm = trainTestNBSVM(bigramsEW, trainingIdx, testIdx);
            
            accuracies1_uni(i) = acc1_uni;
            accuracies1_bi(i) = acc1_bi;
            accuracies1_uni_svm(i) = acc1_uni_svm;
            accuracies1_bi_svm(i) = acc1_bi_svm;
            
            %% Substitutions
            [dist_u, pL_] = calculate_unigrams_distances(trD_uni);
            
            for li = 1:size(param_combinations,1)
                fprintf('Fold: %d/%d, Parameter Combination: %d/%d \n \n', i, abs(fold), li, size(param_combinations,1));
                current_params = num2cell(param_combinations(li,:));
                
                cutoff = param_combinations{li,1};
                a = param_combinations{li,2};
                b = 1 - a;
                maxDistance = param_combinations{li,3};
                linkage = param_combinations{li,4}{1};
                
                fprintf('cutoff: %.2f, a: %.2f, maxDistance: %.2f, linkage: %s\n \n', cutoff, a, maxDistance, linkage);
                
                % Create substitution model                
                clusters = pairwise_clustering(dist_u, pL_, 'Linkage', linkage, 'Cutoff', cutoff, 'ScoreFunctionParam1', a, 'ScoreFunctionParam2', b);
                
                % Get new training model
                [substitutionMap1, clusterWordMap, clusterWordMapVi] = apply_cluster_substitutions(trD_uni, clusters);
                sTrD = trD_uni.applySubstitution(substitutionMap1);
                
                % Map unseen words to clostest cluster
                substitutionMap2 = nearest_cluster_substitution(teD_uni, trD_uni, clusters, clusterWordMapVi, 'Method', methodNearestClusterAssignment, 'MaxDistance', maxDistance);
                
                % Apply both substitutions to test set
                substitutionMap = [substitutionMap1; substitutionMap2];
                sTeD = teD_uni.applySubstitution(substitutionMap);
                
                % Model with substitutions
                sT = cell(size(EW.T));
                sT(trainingIdx) = sTrD.T;
                sT(testIdx) = sTeD.T;
                sY = zeros(size(EW.Y));
                sY(trainingIdx) = EW.Y(trainingIdx);
                sY(testIdx) = EW.Y(testIdx);
                
                sD_uni = io.DocumentSet(sT, sY);
                sWC_uni = sD_uni.wordCountMatrix();
                sWC_uni(sWC_uni>1) = 1;
                
                sD_bi = BigramFinder.generateAllNGrams(sD_uni,2,true);
                sD_bi.wordCountMatrix();
                                
                sWC_bi = sD_bi.W;
                sWC_bi(sWC_bi>1) = 1;
                
                % MNB
                [acc2_uni,p_uni] = trainTestNB(sD_uni,sWC_uni,trainingIdx,testIdx);
                [acc2_bi,p_bi] = trainTestNB(sD_bi,sWC_bi,trainingIdx,testIdx);
                
                % MNBSVM
                acc2_uni_svm = trainTestNBSVM(sD_uni, trainingIdx, testIdx);
                acc2_bi_svm = trainTestNBSVM(sD_bi, trainingIdx, testIdx);
                
                %% Gather results
                accuracies2_uni(i,li) = acc2_uni;
                accuracies2_bi(i,li) = acc2_bi;
                
                accuracies2_uni_svm(i,li) = acc2_uni_svm;
                accuracies2_bi_svm(i,li) = acc2_bi_svm;
                
                p2_uni(i, li) = p_uni;
                p2_bi(i, li) = p_bi;
                
                vocSizeSubs_uni(i,li) = numel(sD_uni.V);
                vocSizeSubs_bi(i,li) = numel(sD_bi.V);
                %%.............................................................
                
                % Show results
                total = sum(testIdx);
                disp('%%%%%%%%%%%%%%%%% NB %%%%%%%%%%%%%%%%%%%%%%%');
                fprintf('Accuracy Unigrams (Orig): %.2f %% (%d/%d) \n', acc1_uni*100, int32(acc1_uni*total), total);
                fprintf('Accuracy Unigrams (Sub): %.2f %% (%d/%d) \n', acc2_uni*100, int32(acc2_uni*total), total);                
                fprintf('Accuracy Bigrams (Orig): %.2f %% (%d/%d) \n', acc1_bi*100, int32(acc1_bi*total), total);
                fprintf('Accuracy Bigrams (Sub): %.2f %% (%d/%d) \n \n', acc2_bi*100, int32(acc2_bi*total), total);
                
                disp('%%%%%%%%%%%%%%%%% NB-SVM %%%%%%%%%%%%%%%%%%%');
                fprintf('Accuracy Unigrams (Orig): %.2f %% (%d/%d) \n', acc1_uni_svm*100, int32(acc1_uni_svm*total), total);
                fprintf('Accuracy Unigrams (Sub): %.2f %% (%d/%d) \n', acc2_uni_svm*100, int32(acc2_uni_svm*total), total);                
                fprintf('Accuracy Bigrams (Orig): %.2f %% (%d/%d) \n', acc1_bi_svm*100, int32(acc1_bi_svm*total), total);
                fprintf('Accuracy Bigrams (Sub): %.2f %% (%d/%d) \n \n', acc2_bi_svm*100, int32(acc2_bi_svm*total), total);
                
            end
        end
        
        %% Save Results
        for li=1:size(param_combinations)
            cutoff = param_combinations(li,1);
            a = param_combinations{li,2};
            b = 1 - a;
            maxDistance = param_combinations{li,3};
            linkage = param_combinations{li,4}{1};
            
            results(li,:) = ...
                {folds(lj), ...
                cutoff, ...
                a, ...
                b, ...
                maxDistance, ...
                linkage, ...
                mean(vocSizeOrigs_uni), ...
                mean(accuracies1_uni), ...
                std(accuracies1_uni), ...
                mean(p1_uni), ...
                mean(accuracies1_uni_svm), ...
                std(accuracies1_uni_svm), ...
                mean(vocSizeOrigs_bi), ...
                mean(accuracies1_bi), ...
                std(accuracies1_bi), ...
                mean(p1_bi), ...
                mean(accuracies1_bi_svm), ...
                std(accuracies1_bi_svm), ...
                mean(vocSizeSubs_uni(:,li)), ...
                mean(accuracies2_uni(:,li)), ...
                std(accuracies2_uni(:,li)), ...
                mean(p2_uni(:,li)), ...
                mean(accuracies2_uni_svm(:,li)), ...
                std(accuracies2_uni_svm(:,li)), ...
                mean(vocSizeSubs_bi(:,li)), ...
                mean(accuracies2_bi(:,li)), ...
                std(accuracies2_bi(:,li)), ...
                mean(p2_bi(:,li)),...
                mean(accuracies2_bi_svm(:,li)), ...
                std(accuracies2_bi_svm(:,li))};
        end
        
        all_results{lj} = results;
    end
    all_results_t = cell2table(vertcat(all_results{:}),'VariableNames', results_fields);
    all_accs_t = all_results_t(:,[1:6 8 20 11 23 14 26 17 29]);
    
    save(fullfile(save_dir, sprintf('business-signal-%d.mat', lk)), 'all_results_t', 'all_accs_t');
end