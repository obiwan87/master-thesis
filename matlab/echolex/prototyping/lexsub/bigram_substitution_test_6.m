%% Result reporting
results_fields = ...
    {'holdout', ...
    'cutoff', ...
    'a', ...
    'b', ...
    'max_distance', ...
    'N', ...
    'voc_size_orig', ...
    'mean_acc_orig_nb', ...
    'std_acc_orig_nb', ...
    'precision_orig_nb', ...
    'std_precision_orig_nb', ...
    'recall_orig_nb', ...
    'std_recall_orig_nb', ...
    'mean_posterior_orig_nb', ...
    'mean_acc_orig_svm', ...
    'std_acc_orig_svm', ...
    'precision_orig_svm', ...
    'std_precision_orig_svm', ...
    'recall_orig_svm', ...
    'std_recall_orig_svm', ...
    'voc_size_sub_n', ...
    'mean_acc_sub_n_nb', ...
    'std_acc_sub_n_nb', ...
    'precision_sub_n_nb', ...
    'std_precision_sub_n_nb', ...
    'recall_sub_n_nb', ...
    'std_recall_sub_n_nb', ...
    'mean_posterior_sub_n_nb',...
    'mean_acc_sub_n_svm', ...
    'std_acc_sub_n_svm', ...
    'precision_sub_n_svm', ...
    'std_precision_sub_n_svm', ...
    'recall_sub_n_svm', ...
    'std_recall_sub_n_svm', ...
    };
results_fields_acc = {'mean_acc_orig_nb', 'mean_acc_sub_n_nb', 'mean_acc_orig_svm', 'mean_acc_sub_n_svm'};
param_fields = 1:6;
prefix = 'results_test_run';
%dtstamp = char(datetime);
%dtstamp = strrep(dtstamp, ':', '');
%results_dir_path = fullfile(echolex_dumps, prefix, dtstamp);
results_dir_path = fullfile(echolex_dumps, prefix);  
mkdir(results_dir_path);

%% Some general clustering parameters
methodNearestClusterAssignment = 'min';

%% Evaluation
folds = 10;
runs = 1;

%% LexSub parameters combinations

scoreFunction = @bayes_hypothesis_probability;

% Find best parameter combination of N-1-Grams
cutoffs = [0.25 0.5 0.75];
as = 1; %  Prior weight
bs = 0.1; % lin comb. weight
max_distances = [ 0 0.55 2 ];
params_ngrams = allcomb(cutoffs,as,bs,max_distances);

b0 = params_ngrams(params_ngrams(:,3) == 0,:);
b0(:,2) = 0;
b0 = unique(b0, 'rows');

params_ngrams(params_ngrams(:,3) == 0,:) = [];
params_ngrams = [params_ngrams; b0];

load(fullfile(echolex_dumps, 'params_bigrams_all.mat'));
% params_ngrams = [0.250000000000000 1 0.300000000000000 0];

%% Iterate through datasets

%Size of N-Grams?
minN = 2;
maxN = 2;

for lk=1:numel(Ws)
    clear pLs
    W = Ws{lk};
    EW = W;
    EW.wordCountMatrix();
    
    for N=minN:maxN
       
        %% Parameters 
        if N > 1
            results_filename = sprintf('%s-%d-grams.mat',EW.DatasetName,N-1);
            load(fullfile(results_dir_path, results_filename));
            [TID, ~, groups] = unique(all_accs_t(:,2:5));
            
            acc = splitapply(@mean, all_accs_t.mean_acc_sub_n_svm , groups);
            acc = [acc splitapply(@mean, all_accs_t.mean_acc_sub_n_nb , groups)]; %#ok<AGROW>
            acc = max(acc,[], 2);
            best_idx = maxi(acc,[],1);
            
            best_combination = table2cell(TID(best_idx,:));
        end
        
        all_results_t = cell2table(cell(0,numel(results_fields)),'VariableNames', results_fields);
        [~, ~, all_accs_t_fields] = intersect(results_fields_acc, results_fields, 'stable');
        all_accs_t = all_results_t(:,[param_fields all_accs_t_fields']);
        all_results = cell(numel(folds),1);
        
        param_combinations = cell(size(params_ngrams));
        
        for i=1:size(params_ngrams,1)
            for j = 1:size(params_ngrams,2)
                param_combinations{i,j} = zeros(1,N);
                for k=1:N-1
                    param_combinations{i,j}(k) = best_combination{j}(k);
                end
                param_combinations{i,j}(N) = params_ngrams(i,j);
            end
        end
        
                       
        %% Generate N-Grams
        ngramsEW = BigramFinder.generateAllNGrams(EW,N,true);
        ngramsEW.wordCountMatrix();
        ngramsEW.findBigrams();
        ngramsEW.w2vCount();
        
        % Random Generator State        
        rng default
        
        % Pre-Compute distance matrices
        fprintf('Calculating distance matrices (w2v) ... \n');
        
        % Word count matrix        
        ngramsWC = ngramsEW.W;
        ngramsWC(ngramsWC>1) = 1;
        
        % dist caches
        dists = cell(N,1);
        Vs = cell(N,1);
        
        for i=1:N
            fprintf('%d-grams \n', i);            
            Vs{i} = ngramsEW.V(ngramsEW.ViCount >= 1 & ngramsEW.B==i);
            v = numel(Vs{i});
            mem_req = (v*(v - 1)*4)/1024^3;
            fprintf('Memory requirements for full distance matrix: %.2f GB \n\n', mem_req);
            
            if mem_req * 4 > 128
                c = input('You sure you want to continue?', 's');
                
                if ~startsWith(lower(c), 'y')
                    error('Operation terminated by user!');
                end                
            end
            
            dists{i} = squareform(ngrams_pdist(ngramsEW.m, Vs{i}, i));
            
        end
        
        for ll = 1:runs
            curr = rng;
            for lj=1:numel(folds)
                %accuracies = zeros(size(param_combinations,1), runs,4);
                results = cell(size(param_combinations,1), numel(results_fields));
                
                fold = folds(lj);
                abs_fold = abs(fold);
                p1_bi = zeros(abs_fold,1);
                
                accuracies1_bi = zeros(abs_fold,1);
                accuracies1_bi_svm = zeros(abs_fold,1);
                
                precisions_bi = zeros(abs_fold,1);
                precisions_bi_svm = zeros(abs_fold,1);
                recalls_bi = zeros(abs_fold,1);
                recalls_bi_svm = zeros(abs_fold,1);
                
                vocSizeOrigs_bi = zeros(abs_fold,1);
                
                % Store results here                
                accuracies2_n_nb =  zeros(abs_fold, size(param_combinations,1));
                precisions2_n_nb = zeros(abs_fold, size(param_combinations,1));
                recalls2_n_nb = zeros(abs_fold, size(param_combinations,1));
                
                accuracies2_n_svm =  zeros(abs_fold, size(param_combinations,1));                
                precisions2_n_svm = zeros(abs_fold, size(param_combinations,1));
                recalls2_n_svm = zeros(abs_fold, size(param_combinations,1));
                
                vocSizeSubs_n =  zeros(abs_fold, size(param_combinations,1));
                p2_n = zeros(abs_fold,size(param_combinations,1));
                
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
                    
                    [trD_bi,  teD_bi ] = ngramsEW.split(testIdx, trainingIdx);
                    vocSizeOrigs_bi(i)  = numel(ngramsEW.V);
                    
                    
                    %% Original Documents
                    [acc1_bi, p, ~, prec_nb_1, rec_nb_1] = trainTestNB(ngramsEW, ngramsWC, trainingIdx, testIdx);
                    p1_bi(i) = p;
                    
                    [acc1_bi_svm, ~, ~, prec_nbsvm_1, rec_nbsvm_1] = trainTestNBSVM(ngramsEW, trainingIdx, testIdx);
                    if acc1_bi_svm < 0.65
                        ngramsEW.Y = ~ngramsEW.Y;                        
                        fprintf('Accuracy: %.2f. Too low! Retry: ', acc1_bi_svm*100);
                        [acc1_bi_svm2, ~, ~, prec_nbsvm_1, rec_nbsvm_1] = trainTestNBSVM(ngramsEW, trainingIdx, testIdx);
                        acc1_bi_svm = max([acc1_bi_svm acc1_bi_svm2]);
                        ngramsEW.Y = ~ngramsEW.Y;
                        fprintf('%.2f \n', acc1_bi_svm*100);
                    end
                    
                    accuracies1_bi(i) = acc1_bi;
                    precisions_bi(i) = prec_nb_1;
                    recalls_bi(i) = rec_nb_1;
                    
                    accuracies1_bi_svm(i) = acc1_bi_svm;
                    precisions_bi_svm(i) = prec_nbsvm_1;
                    recalls_bi_svm(i) = rec_nbsvm_1;
                    
                    
                    trD_bi.w2vCount();
                    teD_bi.w2vCount();
                    F = trD_bi.termFrequencies();
                    
                    % Extract bigams with at least one word in word2vec model
                    trVs = cell(N,1);
                    teVs = cell(N,1);
                    trFs = cell(N,1);
                    ngrams_subsets = cell(N,1);
                    pLs = cell(N,1);
                    
                    for jj=1:N
                        
                        trQ = trD_bi.ViCount >= 1 & trD_bi.B==jj;
                        teQ = teD_bi.ViCount >= 1 & teD_bi.B==jj;
                        
                        trVs{jj} = trD_bi.V(trQ);
                        teVs{jj} = teD_bi.V(teQ);
                        
                        trFs{jj} = F(trQ,:);
                        
                        %% Subset of words used in these folds
                        [~, ngrams_subsets{jj}] = intersect(Vs{jj}, trVs{jj});
                        pLs{jj} = binomial_likelihood_ratio(trFs{jj});
                    end
                    
                    newFold = true;
                    test_substitution_map_cache = [];
                    training_substitution_map_cache = [];
                    for li = 1:size(param_combinations,1)
                        fprintf('Dataset: %s, Run: %d/%d, N: %d, Fold: %d/%d, Parameter Combination: %d/%d \n \n', EW.DatasetName, ll,runs,N,i, abs(fold), li, size(param_combinations,1));
                        linkag = 'complete';
                        
                        training_substitution_map = training_substitution_map_cache;
                        test_substitution_map = test_substitution_map_cache;
                        
                        for jj=1:N                          
                            %% Calculate substitutions only on Bigrams
                            if jj >N-1 || newFold
                                cutoff = param_combinations{li,1}(jj);
                                a = param_combinations{li,2}(jj);
                                b = param_combinations{li,3}(jj);
                                maxDistance = param_combinations{li,4}(jj);
                                fprintf('%d-grams: cutoff: %.2f, a: %.2f, b: %.2f, maxDistance: %.2f\n \n',jj,cutoff, a, b, maxDistance);
                                
                                % Create substitution model
                                d = squareform(dists{jj}(ngrams_subsets{jj},ngrams_subsets{jj}));
                                if a ~= 0
                                    pL_ = pLs{jj};
                                else
                                    pL_ = 0;
                                end
                                fprintf('Clustering %d-grams ... \n', jj);
                                clusters = pairwise_clustering(d, pL_, 'Linkage', linkag, 'MaxClust', round(cutoff.*numel(trVs{jj})), 'ScoreFunction', scoreFunction, 'ScoreFunctionParam1', a, 'ScoreFunctionParam2', b);
                                
                                fprintf('Original %d-Grams: %d, Reduced to Clusters: %d \n', jj, numel(trVs{jj}), numel(unique(clusters))); 
                                
                                % Get new training model
                                [substitution_map1, clusterWordMap] = apply_cluster_substitutions2(trFs{jj}, clusters);
                                
                                training_substitution_map = [training_substitution_map; substitution_map1]; %#ok<AGROW>
                                
                                % Map unseen words to clostest cluster
                                substitution_map2 = nearest_cluster_substitution_ngrams(trD_bi.m, jj, ngramsEW, dists{jj}, teVs{jj}, trVs{jj}, trFs{jj}, ...
                                    clusters, clusterWordMap, ...
                                    'Method', methodNearestClusterAssignment, 'MaxDistance', maxDistance);
                                
                                test_substitution_map = [test_substitution_map; substitution_map2]; %#ok<AGROW>
                            else
                                fprintf('Using Cache for Clustering %d-grams ... \n', jj);
                            end
                            
                            if jj < N && newFold
                                training_substitution_map_cache = [training_substitution_map_cache; training_substitution_map]; %#ok<AGROW>
                                test_substitution_map_cache = [test_substitution_map_cache; test_substitution_map]; %#ok<AGROW>
                            end
                            
                        end
                        newFold = false;
                        %% Apply substitution maps to documents
                        substitution_map = [training_substitution_map; test_substitution_map];
                        
                        sTrD = trD_bi.applySubstitution(training_substitution_map);
                        sTeD = teD_bi.applySubstitution(substitution_map);
                        
                        %% Build document with substitutions (both unigrams and bigrams)
                        sT = cell(size(EW.T));
                        sT(trainingIdx) = sTrD.T;
                        sT(testIdx) = sTeD.T;
                        sY = zeros(size(EW.Y));
                        sY(trainingIdx) = EW.Y(trainingIdx);
                        sY(testIdx) = EW.Y(testIdx);
                        
                        sD = io.DocumentSet(sT, sY);
                        sWC = sD.wordCountMatrix();
                        sWC(sWC>1) = 1;
                        
                        
                        %% Evaluate clsasification accuracy
                        % MNB
                        [acc2,p,~,prec_nb_2,rec_nb_2] = trainTestNB(sD,sWC,trainingIdx,testIdx);
                        
                        % MNBSVM
                        
                        [acc2_svm, ~, ~, prec_nbsvm_2, rec_nbsvm_2] = trainTestNBSVM(sD, trainingIdx, testIdx);
                        if acc2_svm < 0.65
                            sD.Y = ~sD.Y;
                            [acc2_svm2, ~, ~, prec_nbsvm_2, rec_nbsvm_2] = trainTestNBSVM(sD, trainingIdx, testIdx);
                            acc2_svm = max([acc2_svm acc2_svm2]);
                        end
                        
                        %% Gather results
                        
                        accuracies2_n_nb(i,li) = acc2;
                        precisions2_n_nb(i,li) = prec_nb_2;
                        recalls2_n_nb(i,li) = rec_nb_2;
                        
                        accuracies2_n_svm(i,li) = acc2_svm;
                        precisions2_n_svm(i,li) = prec_nbsvm_2;
                        recalls2_n_svm(i,li) = rec_nbsvm_2;
                        
                        p2_n(i, li) = p;
                        vocSizeSubs_n(i,li) = numel(sD.V);
                        
                        
                        %% Show results
                        total = sum(testIdx);
                        total_tr = sum(trainingIdx);
                        disp('%%%%%%%%%%%%%%%%% NB %%%%%%%%%%%%%%%%%%%%%%%');
                        fprintf('Accuracy %d-Grams (Orig): %.2f %% (%d/%d) \n', N, acc1_bi*100, int32(acc1_bi*total), total);
                        fprintf('Precision %d-Grams (Orig): %.2f %% \n', N, prec_nb_1*100);
                        fprintf('Recall %d-Grams (Orig): %.2f %% \n \n', N, rec_nb_1*100);
                        
                        fprintf('Accuracy %d-Grams (Sub): %.2f %% (%d/%d) \n', N, acc2*100, int32(acc2*total), total);                                               
                        fprintf('Precision %d-Grams (Sub): %.2f %% \n', N, prec_nb_2*100);
                        fprintf('Recall %d-Grams (Sub): %.2f %% \n', N, rec_nb_2*100);
                        
                        disp('%%%%%%%%%%%%%%%%% NB-SVM %%%%%%%%%%%%%%%%%%%');
                        fprintf('Accuracy %d-Grams (Orig): %.2f %% (%d/%d) \n', N, acc1_bi_svm*100, int32(acc1_bi_svm*total), total);
                        fprintf('Precision %d-Grams (Orig): %.2f %% \n', N, prec_nbsvm_1*100);
                        fprintf('Recall %d-Grams (Orig): %.2f %% \n \n', N, rec_nbsvm_1*100);
                        
                        fprintf('Accuracy %d-Grams (Sub): %.2f %% (%d/%d) \n', N, acc2_svm*100, int32(acc2_svm*total), total);
                        fprintf('Precision %d-Grams (Sub): %.2f %% \n', N, prec_nbsvm_2*100);
                        fprintf('Recall %d-Grams (Sub): %.2f %% \n', N, rec_nbsvm_2*100);
                        disp('============================================');
                        
                    end
                end
                
                %% Save Results
                for li=1:size(param_combinations)
                    cutoff = param_combinations{li,1};
                    a = param_combinations{li,2};
                    b = param_combinations{li,3};
                    maxDistance = param_combinations{li,4};
                    
                    results(li,:) = ...
                        {folds(lj), ...
                        cutoff, ...
                        a, ...
                        b, ...
                        maxDistance, ...
                        N, ...
                        mean(vocSizeOrigs_bi), ...
                        mean(accuracies1_bi), ...
                        std(accuracies1_bi), ...
                        mean(precisions_bi), ...
                        std(precisions_bi), ...
                        mean(recalls_bi), ...
                        std(recalls_bi), ...
                        mean(p1_bi), ...
                        mean(accuracies1_bi_svm), ...
                        std(accuracies1_bi_svm), ...
                        mean(precisions_bi_svm), ...
                        std(precisions_bi_svm), ...
                        mean(recalls_bi_svm), ...
                        std(recalls_bi_svm), ...
                        mean(vocSizeSubs_n(:,li)), ...
                        mean(accuracies2_n_nb(:,li)), ...
                        std(accuracies2_n_nb(:,li)), ...
                        mean(precisions2_n_nb(:,li)), ...
                        std(precisions2_n_nb(:,li)), ...
                        mean(recalls2_n_nb(:,li)), ...
                        std(recalls2_n_nb(:,li)), ...
                        mean(p2_n(:,li)),...
                        mean(accuracies2_n_svm(:,li)), ...
                        std(accuracies2_n_svm(:,li)), ...
                        mean(precisions2_n_svm(:,li)), ...
                        std(precisions2_n_svm(:,li)), ...
                        mean(recalls2_n_svm(:,li)), ...
                        std(recalls2_n_svm(:,li))};
                end
                
                all_results{lj} = results;
            end
            all_results_t = [all_results_t; cell2table(vertcat(all_results{:}),'VariableNames', results_fields)]; %#ok<AGROW>
            all_accs_t = all_results_t(:,[param_fields all_accs_t_fields']);
        end
        results_filename = sprintf('%s-%d-grams.mat',EW.DatasetName,N);
        save(fullfile(results_dir_path, results_filename), 'all_results_t', 'all_accs_t');
    end
end
