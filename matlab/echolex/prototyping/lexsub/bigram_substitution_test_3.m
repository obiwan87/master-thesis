%for lk = 1:7
N = 2;

W = Ws{7};
W = io.Word2VecDocumentSet(W.m, W.T(1:100), W.Y(1:100));
EW = W;
EW.wordCountMatrix();
% ngramsEW = bigramsWs{2};
ngramsEW = BigramFinder.generateAllNGrams(EW,N,true);
ngramsEW.wordCountMatrix();
ngramsEW.findBigrams();

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
    'std_acc_sub_bi_svm'};

results_fields_acc = {'mean_acc_orig_bi_nb', 'mean_acc_sub_bi_nb', 'mean_acc_orig_bi_svm', 'mean_acc_sub_bi_svm'};
useGpu = false;
evaluateSubstitutionAppending = false;


%% Parameters
cutoffs = 0.4;
as = 0;%[0 0.05 0.1 0.2];
scoreFunction = @(pL_,dists,a,b) pL_*a + dists/2*b;
%scoreFunction = @(pL_,dists,a,b) minkowski(cat(3,1-2*pL_,dists/2),a,3);
%scoreFunction = @(pL_,dists,a,b) max(cat(3,pL_,dists/2),[],3);
maxDistances = 0.5;
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
[~, all_accs_t_fields] = intersect(results_fields, results_fields_acc);
all_accs_t = all_results_t(:,all_accs_t_fields);

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
    vocSizeSubs_bi =  zeros(abs_fold, size(param_combinations,1));    
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
        
        [trD_bi,  teD_bi ] = ngramsEW.split(testIdx, trainingIdx);        
        vocSizeOrigs_bi(i)  = numel(ngramsEW.V);
        
        %% Original Documents
                
        [acc1_bi, p_bi] = trainTestNB(ngramsEW, bigramsWC, trainingIdx, testIdx);
        p1_bi(i) = p_bi;
        
        acc1_bi_svm = trainTestNBSVM(ngramsEW, trainingIdx, testIdx);        
        acc1_bi_resub_svm = trainTestNBSVM(EW, trainingIdx, trainingIdx);        

        accuracies1_bi(i) = acc1_bi;
        accuracies1_bi_svm(i) = acc1_bi_svm;
        
        %% Substitutions        
        trD_bi.w2vCount();
        teD_bi.w2vCount();
        
        trV = trD_bi.V(trD_bi.ViCount >= 1 & trD_bi.B==2);
        teV = teD_bi.V(teD_bi.ViCount >= 1 & teD_bi.B==2);
        F = trD_bi.termFrequencies();
        trF = F(trD_bi.ViCount >= 1 & trD_bi.B==2,:);
        
        dist_u = words_pdist2(trD_bi.m, trV, trV);
        pL_ = normalized_kld(trF, trD_bi.Y);
        
        for li = 1:size(param_combinations,1)
            fprintf('Fold: %d/%d, Parameter Combination: %d/%d \n \n', i, abs(fold), li, size(param_combinations,1));
            current_params = num2cell(param_combinations(li,:));
            
            cutoff = param_combinations{li,1};
            a = param_combinations{li,2};
            b = 1 - a;
            maxDistance = param_combinations{li,3};
            linkag = param_combinations{li,4}{1};
            
            fprintf('cutoff: %.2f, a: %.2f, maxDistance: %.2f, linkage: %s\n \n', cutoff, a, maxDistance, linkag);
            if substituteModel
                % Create substitution model
                clusters = pairwise_clustering(dist_u, pL_, 'Linkage', linkag, 'Cutoff', cutoff, 'ScoreFunction', scoreFunction, 'ScoreFunctionParam1', a, 'ScoreFunctionParam2', b);
                
                % Get new training model
                [substitutionMap1, clusterWordMap] = apply_cluster_substitutions2(trF, clusters);
                sTrD = trD_bi.applySubstitution(substitutionMap1);
            else
                clusters = 1:sum(trD_uni.Vi ~= 0);
                clusterWordMap = trD_uni.V(trD_uni.Vi ~= 0);
                substitutionMap1 = containers.Map;
                sTrD = trD_uni;
            end
            
            % Map unseen words to clostest cluster
            substitutionMap2 = nearest_cluster_substitution_ngrams(trD_bi.m, teV, trV, trF, clusters, clusterWordMap, 'Method', methodNearestClusterAssignment, 'MaxDistance', maxDistance);
            
            % Apply both substitutions to test set
            substitutionMap = [substitutionMap1; substitutionMap2];
            sTeD = teD_bi.applySubstitution(substitutionMap);
            
            % Model with substitutions
            sT = cell(size(EW.T));
            sT(trainingIdx) = sTrD.T;
            sT(testIdx) = sTeD.T;
            sY = zeros(size(EW.Y));
            sY(trainingIdx) = EW.Y(trainingIdx);
            sY(testIdx) = EW.Y(testIdx);
            
            sD_bi = io.DocumentSet(sT, sY);
            sWC_bi = sD_bi.wordCountMatrix();
            sWC_bi(sWC_bi>1) = 1;
                       
            % MNB
            [acc2_bi,p_bi] = trainTestNB(sD_bi,sWC_bi,trainingIdx,testIdx);
            
            % MNBSVM
            acc2_uni_svm = trainTestNBSVM(sD_bi, trainingIdx, testIdx);
            acc2_bi_svm = trainTestNBSVM(sD_bi, trainingIdx, testIdx);
            
            acc2_bi_resub_svm = trainTestNBSVM(sD_bi, trainingIdx, trainingIdx);
            
            %% Gather results
            
            
            accuracies2_bi(i,li) = acc2_bi;
            accuracies2_bi_svm(i,li) = acc2_bi_svm;
            p2_bi(i, li) = p_bi;
            
            vocSizeSubs_bi(i,li) = numel(sD_bi.V);
            %%.............................................................
            
            % Show results
            total = sum(testIdx);
            total_tr = sum(trainingIdx);
            disp('%%%%%%%%%%%%%%%%% NB %%%%%%%%%%%%%%%%%%%%%%%');                                    
            fprintf('Accuracy Bigrams (Orig): %.2f %% (%d/%d) \n', acc1_bi*100, int32(acc1_bi*total), total);
            fprintf('Accuracy Bigrams (Sub): %.2f %% (%d/%d) \n', acc2_bi*100, int32(acc2_bi*total), total);
            
            disp('%%%%%%%%%%%%%%%%% NB-SVM %%%%%%%%%%%%%%%%%%%');
            fprintf('Accuracy Bigrams (Orig): %.2f %% (%d/%d) \n', acc1_bi_svm*100, int32(acc1_bi_svm*total), total);            
            fprintf('Accuracy Bigrams (Sub): %.2f %% (%d/%d) \n', acc2_bi_svm*100, int32(acc2_bi_svm*total), total);            
            
        end
    end
    
    %% Save Results
    for li=1:size(param_combinations)
        cutoff = param_combinations(li,1);
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
            std(accuracies2_bi_svm(:,li))};
    end
    
    all_results{lj} = results;
end
all_results_t = [all_results_t; cell2table(vertcat(all_results{:}),'VariableNames', results_fields)];
all_accs_t = all_results_t(:,all_accs_t_fields);
end
%save(sprintf('business-signal-%d.mat',lk), 'all_results_t', 'all_accs_t');
%end