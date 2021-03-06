lk = 2;
N = 2;
W = Ws{lk};

EW = W;
EW.wordCountMatrix();
% ngramsEW = bigramsWs{2};
ngramsEW = BigramFinder.generateAllNGrams(EW,N,true);
ngramsEW.wordCountMatrix();
ngramsEW.findBigrams();
ngramsEW.w2vCount();

results_fields = ...
    {'holdout', ...
    'cutoff', ...
    'a', ...
    'b', ...
    'max_distance', ...
    'linkage', ...
    'voc_size_orig_bi', ...
    'mean_acc_orig_bi_nb', ...
    'std_acc_orig_bi_nb', ...
    'mean_posterior_orig_bi_nb', ...
    'mean_acc_orig_bi_svm', ...
    'std_acc_orig_bi_svm', ...
    'voc_size_sub_bi', ...
    'mean_acc_sub_bi_nb', ...
    'std_acc_sub_bi_nb', ...
    'mean_posterior_sub_bi_nb',...
    'mean_acc_sub_bi_svm', ...
    'std_acc_sub_bi_svm', ...
    'voc_size_sub_both', ...
    'mean_acc_sub_both_nb', ...
    'std_acc_sub_both_nb', ...
    'mean_posterior_sub_both_nb',...
    'mean_acc_sub_both_svm', ...
    'std_acc_sub_both_svm'};

results_fields_acc = {'mean_acc_orig_bi_nb', 'mean_acc_sub_bi_nb', 'mean_acc_sub_both_nb', 'mean_acc_orig_bi_svm', 'mean_acc_sub_bi_svm', 'mean_acc_sub_both_svm'};
useGpu = false;
evaluateSubstitutionAppending = false;


%% Parameters
cutoffs = [0.1 0.15 0.2 0.25];
as = [0.05 0.1 0.2 0.3 0.4 0.5];%[0 0.05 0.1 0.2];
scoreFunction = @(pL_,dists,a,b) pL_*a + dists/2*b;
%scoreFunction = @(pL_,dists,a,b) minkowski(cat(3,1-2*pL_,dists/2),a,3);
%scoreFunction = @(pL_,dists,a,b) max(cat(3,pL_,dists/2),[],3);
maxDistances = 0.6;
divergence = 'bernoulli';
linkages = {'complete'};
methodNearestClusterAssignment = 'average';
param_combinations = allcomb(num2cell(cutoffs), num2cell(as), num2cell(maxDistances), num2cell(linkages));

%% Evaluation
folds = 10;
runs = 1;

all_results = cell(numel(folds),1);

% Word count matrix
unigramsWC = EW.W;
unigramsWC(unigramsWC>1) = 1;

bigramsWC = ngramsEW.W;
bigramsWC(bigramsWC>1) = 1;

% Random Generator State
all_results_t = cell2table(cell(0,numel(results_fields)),'VariableNames', results_fields);
[~, ~, all_accs_t_fields] = intersect(results_fields_acc, results_fields, 'stable');
all_accs_t = all_results_t(:,[1:6 all_accs_t_fields']);
rng default

% Pre-Compute distance matrices
fprintf('Calculating distance matrices (w2v) ... \n');
V_bi = ngramsEW.V(ngramsEW.ViCount >= 1 & ngramsEW.B==2);
V_uni = ngramsEW.V(ngramsEW.ViCount >= 1 & ngramsEW.B==1);

dist_uni = squareform(ngrams_pdist(ngramsEW.m, V_uni, 1));
dist_bi = squareform(ngrams_pdist(ngramsEW.m, V_bi, 2));

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
        vocSizeOrigs_bi = zeros(abs_fold,1);
        
        % Store results here
        
        accuracies2_bi =  zeros(abs_fold, size(param_combinations,1));
        accuracies2_bi_svm =  zeros(abs_fold, size(param_combinations,1));
        
        accuracies2_both =  zeros(abs_fold, size(param_combinations,1));
        accuracies2_both_svm =  zeros(abs_fold, size(param_combinations,1));
                
        vocSizeSubs_bi =  zeros(abs_fold, size(param_combinations,1));
        vocSizeSubs_both =  zeros(abs_fold, size(param_combinations,1));
        p2_bi = zeros(abs_fold,size(param_combinations,1));
        p2_both = zeros(abs_fold,size(param_combinations,1));
        
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
            
            [acc1_bi, p_both] = trainTestNB(ngramsEW, bigramsWC, trainingIdx, testIdx);
            p1_bi(i) = p_both;
            
            acc1_bi_svm = trainTestNBSVM(ngramsEW, trainingIdx, testIdx);
            acc1_bi_resub_svm = trainTestNBSVM(EW, trainingIdx, trainingIdx);
            
            accuracies1_bi(i) = acc1_bi;
            accuracies1_bi_svm(i) = acc1_bi_svm;
            
            %% Substitutions
            trD_bi.w2vCount();
            teD_bi.w2vCount();
            
            % Extract bigams with at least one word in word2vec model

            %Free Memory
            clear pL_bi pL_uni
            
            % Extract bigams with at least one word in word2vec model
            trV_bi = trD_bi.V(trD_bi.ViCount >= 1 & trD_bi.B==2);
            teV_bi = teD_bi.V(teD_bi.ViCount >= 1 & teD_bi.B==2);
                        
            F = trD_bi.termFrequencies();
            trF_bi = F(trD_bi.ViCount >= 1 & trD_bi.B==2,:);            
            
            % Extract unigrams in word2vec model
            trV_uni = trD_bi.V(trD_bi.ViCount >= 1 & trD_bi.B==1);
            teV_uni = teD_bi.V(teD_bi.ViCount >= 1 & teD_bi.B==1);
                        
            trF_uni = F(trD_bi.ViCount >= 1 & trD_bi.B==1,:);  
            
            %% Subset of words used in these folds
            [~, bi_subset] = intersect(V_bi, trV_bi);
            [~, uni_subset] = intersect(V_uni, trD_bi.V);
            
            if strcmp(divergence,'bernoulli')
                pL_bi = squareform(bernoulli_divergence(trF_bi));
                pL_uni = squareform(bernoulli_divergence(trF_uni));
            else
                pL_bi = normalized_kld(trF_bi, trD_bi.Y);
                pL_uni = normalized_kld(trF_uni, trD_bi.Y);
            end
            
            for li = 1:size(param_combinations,1)
                fprintf('Fold: %d/%d, Parameter Combination: %d/%d \n \n', i, abs(fold), li, size(param_combinations,1));
                current_params = num2cell(param_combinations(li,:));
                
                cutoff = param_combinations{li,1};
                a = param_combinations{li,2};
                b = 1 - a;
                maxDistance = param_combinations{li,3};
                linkag = param_combinations{li,4}{1};
                
                fprintf('cutoff: %.2f, a: %.2f, maxDistance: %.2f, linkage: %s\n \n', cutoff, a, maxDistance, linkag);
                
                %% Calculate substitutions only on Bigrams
                
                % Create substitution model
                clusters_bi = pairwise_clustering(dist_bi(bi_subset,bi_subset), pL_bi, 'Linkage', linkag, 'Cutoff', cutoff, 'ScoreFunction', scoreFunction, 'ScoreFunctionParam1', a, 'ScoreFunctionParam2', b);
                
                % Get new training model
                [substitutionMap1, clusterWordMap_bi] = apply_cluster_substitutions2(trF_bi, clusters_bi);                
                
                % Map unseen words to clostest cluster
                substitutionMap2 = nearest_cluster_substitution_ngrams(trD_bi.m, teV_bi, trV_bi, trF_bi, ...
                    clusters_bi, clusterWordMap_bi, ...
                    'Method', methodNearestClusterAssignment, 'MaxDistance', maxDistance);
                
                 %% Calculate substitutions only on Unigrams
                
                % Create substitution model
                clusters_uni = pairwise_clustering(dist_uni(uni_subset,uni_subset), pL_uni, 'Linkage', linkag, 'Cutoff', cutoff, 'ScoreFunction', scoreFunction, 'ScoreFunctionParam1', a, 'ScoreFunctionParam2', b);
                
                % Get new training model
                [substitutionMap3, clusterWordMap_uni] = apply_cluster_substitutions2(trF_uni, clusters_uni);
                

                % Map unseen words to clostest cluster
                substitutionMap4 = nearest_cluster_substitution_ngrams(trD_bi.m, teV_uni, trV_uni, trF_uni, ...
                    clusters_uni, clusterWordMap_uni, ...
                    'Method', methodNearestClusterAssignment, 'MaxDistance', maxDistance);
                
                %% Apply substitution maps to documents
                substitutionMap = [substitutionMap1; substitutionMap2; substitutionMap3; substitutionMap4];
                
                sTrD_both = trD_bi.applySubstitution([substitutionMap1; substitutionMap3]);
                sTeD_both = teD_bi.applySubstitution(substitutionMap);
                
                sTrD_bi = trD_bi.applySubstitution(substitutionMap1);
                sTeD_bi = teD_bi.applySubstitution([substitutionMap1; substitutionMap2]);
                
                %% Build document with substitutions (both unigrams and bigrams)
                sT = cell(size(EW.T));
                sT(trainingIdx) = sTrD_both.T;
                sT(testIdx) = sTeD_both.T;
                sY = zeros(size(EW.Y));
                sY(trainingIdx) = EW.Y(trainingIdx);
                sY(testIdx) = EW.Y(testIdx);
                
                sD_both = io.DocumentSet(sT, sY);
                sWC_both = sD_both.wordCountMatrix();
                sWC_both(sWC_both>1) = 1;
                
                %% Build document with substitutions (only bigrams)
                sT = cell(size(EW.T));
                sT(trainingIdx) = sTrD_bi.T;
                sT(testIdx) = sTeD_bi.T;
                sY = zeros(size(EW.Y));
                sY(trainingIdx) = EW.Y(trainingIdx);
                sY(testIdx) = EW.Y(testIdx);
                
                sD_bi = io.DocumentSet(sT, sY);
                sWC_bi = sD_bi.wordCountMatrix();
                sWC_bi(sWC_bi>1) = 1;
                
                %% Evaluate clsasification accuracy
                % MNB
                [acc2_both,p_both] = trainTestNB(sD_both,sWC_both,trainingIdx,testIdx);
                
                % MNBSVM
                acc2_both_svm = trainTestNBSVM(sD_both, trainingIdx, testIdx);
                
                % MNB
                [acc2_bi,p_bi] = trainTestNB(sD_bi,sWC_bi,trainingIdx,testIdx);
                
                % MNBSVM
                acc2_bi_svm = trainTestNBSVM(sD_bi, trainingIdx, testIdx);
                
               
                %% Gather results                
                
                accuracies2_both(i,li) = acc2_both;
                accuracies2_both_svm(i,li) = acc2_both_svm;
                
                accuracies2_bi(i,li) = acc2_bi;
                accuracies2_bi_svm(i,li) = acc2_bi_svm;
                
                p2_bi(i, li) = p_bi;
                p2_both(i, li) = p_both;
                
                vocSizeSubs_bi(i,li) = numel(sD_bi.V);
                vocSizeSubs_both(i,li) = numel(sD_both.V);
                
                
                %% Show results
                total = sum(testIdx);
                total_tr = sum(trainingIdx);
                disp('%%%%%%%%%%%%%%%%% NB %%%%%%%%%%%%%%%%%%%%%%%');
                fprintf('Accuracy Bigrams (Orig): %.2f %% (%d/%d) \n', acc1_bi*100, int32(acc1_bi*total), total);
                fprintf('Accuracy Bigrams (Sub): %.2f %% (%d/%d) \n', acc2_bi*100, int32(acc2_bi*total), total);
                fprintf('Accuracy Bigrams (Sub, Both): %.2f %% (%d/%d) \n', acc2_both*100, int32(acc2_both*total), total);
                
                
                disp('%%%%%%%%%%%%%%%%% NB-SVM %%%%%%%%%%%%%%%%%%%');
                fprintf('Accuracy Bigrams (Orig): %.2f %% (%d/%d) \n', acc1_bi_svm*100, int32(acc1_bi_svm*total), total);
                fprintf('Accuracy Bigrams (Sub): %.2f %% (%d/%d) \n', acc2_bi_svm*100, int32(acc2_bi_svm*total), total);
                fprintf('Accuracy Bigrams (Sub, Both): %.2f %% (%d/%d) \n', acc2_both_svm*100, int32(acc2_both_svm*total), total);
                
            end
        end
        
        %% Save Results
        for li=1:size(param_combinations)
            cutoff = param_combinations{li,1};
            a = param_combinations{li,2};
            b = 1 - a;
            maxDistance = param_combinations{li,3};
            linkag = param_combinations{li,4}{1};
            
            results(li,:) = ...
                {folds(lj), ...
                cutoff, ...
                a, ...
                b, ...
                maxDistance, ...
                linkag, ...
                mean(vocSizeOrigs_bi), ...
                mean(accuracies1_bi), ...
                std(accuracies1_bi), ...
                mean(p1_bi), ...
                mean(accuracies1_bi_svm), ...
                std(accuracies1_bi_svm), ...
                mean(vocSizeSubs_bi(:,li)), ...
                mean(accuracies2_bi(:,li)), ...
                std(accuracies2_bi(:,li)), ...
                mean(p2_bi(:,li)),...
                mean(accuracies2_bi_svm(:,li)), ...
                std(accuracies2_bi_svm(:,li)),...
                mean(vocSizeSubs_both(:,li)), ...
                mean(accuracies2_both(:,li)), ...
                std(accuracies2_both(:,li)), ...
                mean(p2_both(:,li)),...
                mean(accuracies2_both_svm(:,li)), ...
                std(accuracies2_both_svm(:,li))};
        end
        
        all_results{lj} = results;
    end
    all_results_t = [all_results_t; cell2table(vertcat(all_results{:}),'VariableNames', results_fields)];
    all_accs_t = all_results_t(:,[1:6 all_accs_t_fields']);
end
%save(sprintf('business-signal-%d.mat',lk), 'all_results_t', 'all_accs_t');
