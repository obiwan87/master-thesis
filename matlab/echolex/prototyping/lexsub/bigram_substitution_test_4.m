lk = 2;
N = 4;
W = Ws{lk};

EW = W;
EW.wordCountMatrix();
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
    'voc_size_orig', ...
    'mean_acc_orig_nb', ...
    'std_acc_orig_nb', ...
    'mean_posterior_orig_nb', ...
    'mean_acc_orig_svm', ...
    'std_acc_orig_svm', ...
    'voc_size_sub_n', ...
    'mean_acc_sub_n_nb', ...
    'std_acc_sub_n_nb', ...
    'mean_posterior_sub_n_nb',...
    'mean_acc_sub_n_svm', ...
    'std_acc_sub_n_svm', ...
    };

results_fields_acc = {'mean_acc_orig_nb', 'mean_acc_sub_n_nb', 'mean_acc_orig_svm', 'mean_acc_sub_n_svm'};
useGpu = false;
evaluateSubstitutionAppending = false;


%% Parameters
cutoffs = [0.3];% 0.3 0.4];
as = [0];% 0.1 0.2 0.3];%[0 0.05 0.1 0.2];
scoreFunction = @(pL_,dists,a,b) pL_*a + dists/2*b;
%scoreFunction = @(pL_,dists,a,b) minkowski(cat(3,1-2*pL_,dists/2),a,3);
%scoreFunction = @(pL_,dists,a,b) max(cat(3,pL_,dists/2),[],3);
maxDistances = [0.4 0.5 ];% 0.5 0.6];
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

dists = cell(N,1);
Vs = cell(N,1);

for i=1:N
    Vs{i} = ngramsEW.V(ngramsEW.ViCount >= 1 & ngramsEW.B==i);
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
        vocSizeOrigs_bi = zeros(abs_fold,1);
        
        % Store results here
               
        accuracies2_n_nb =  zeros(abs_fold, size(param_combinations,1));
        accuracies2_n_svm =  zeros(abs_fold, size(param_combinations,1));
                
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
            
            [acc1_bi, p] = trainTestNB(ngramsEW, bigramsWC, trainingIdx, testIdx);
            p1_bi(i) = p;
            
            acc1_bi_svm = trainTestNBSVM(ngramsEW, trainingIdx, testIdx);
            acc1_bi_resub_svm = trainTestNBSVM(EW, trainingIdx, trainingIdx);
            
            accuracies1_bi(i) = acc1_bi;
            accuracies1_bi_svm(i) = acc1_bi_svm;
            
            
            trD_bi.w2vCount();
            teD_bi.w2vCount();
            F = trD_bi.termFrequencies();
            
            %Free Memory
            clear pL_bi pL_uni
            
            % Extract bigams with at least one word in word2vec model
            trVs = cell(N,1);
            teVs = cell(N,1);    
            trFs = cell(N,1);
            ngrams_subsets = cell(N,1);
            pLs = cell(N,1);
            
            calc_divergence = any(cell2mat(param_combinations(:,2)) ~= 0);
            for jj=1:N
                             
                trQ = trD_bi.ViCount >= 1 & trD_bi.B==jj;
                teQ = teD_bi.ViCount >= 1 & teD_bi.B==jj;
                
                trVs{jj} = trD_bi.V(trQ);
                teVs{jj} = teD_bi.V(teQ);
                                
                trFs{jj} = F(trQ,:);
                
                %% Subset of words used in these folds
                [~, ngrams_subsets{jj}] = intersect(Vs{jj}, trVs{jj});           
                if calc_divergence
                    pLs{jj} = bernoulli_divergence(trFs{jj});                
                else
                    pLs{jj} = 0;                
                end
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
                
                training_substitution_map = [];
                test_substitution_map = [];
                
                for jj=1:N
                %% Calculate substitutions only on Bigrams
                
                % Create substitution model
                d = squareform(dists{jj}(ngrams_subsets{jj},ngrams_subsets{jj}));
                if a ~= 0
                    pL_ = pLs{jj};
                else
                    pL_ = 0;
                end
                clusters = pairwise_clustering(d, pL_, 'Linkage', linkag, 'Cutoff', cutoff, 'ScoreFunction', scoreFunction, 'ScoreFunctionParam1', a, 'ScoreFunctionParam2', b);
                
                % Get new training model
                [substitution_map1, clusterWordMap] = apply_cluster_substitutions2(trFs{jj}, clusters);                
                
                training_substitution_map = [training_substitution_map; substitution_map1]; %#ok<AGROW>
                
                % Map unseen words to clostest cluster
                substitution_map2 = nearest_cluster_substitution_ngrams(trD_bi.m, teVs{jj}, trVs{jj}, trFs{jj}, ...
                    clusters, clusterWordMap, ...
                    'Method', methodNearestClusterAssignment, 'MaxDistance', maxDistance);
                 
                test_substitution_map = [test_substitution_map; substitution_map2]; %#ok<AGROW>
                
                end
                %% Apply substitution maps to documents
                substitution_map = [training_substitution_map; test_substitution_map];
                
                sTrD = trD_bi.applySubstitution(training_substitution_map);
                sTeD = teD_bi.applySubstitution(test_substitution_map);
                
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
                [acc2,p] = trainTestNB(sD,sWC,trainingIdx,testIdx);
                
                % MNBSVM
                acc2_svm = trainTestNBSVM(sD, trainingIdx, testIdx);
                 
                %% Gather results                
                
                accuracies2_n_nb(i,li) = acc2;
                accuracies2_n_svm(i,li) = acc2_svm;
              
                p2_n(i, li) = p;
                vocSizeSubs_n(i,li) = numel(sD.V);
                
                
                %% Show results
                total = sum(testIdx);
                total_tr = sum(trainingIdx);
                disp('%%%%%%%%%%%%%%%%% NB %%%%%%%%%%%%%%%%%%%%%%%');
                fprintf('Accuracy %d-Grams (Orig): %.2f %% (%d/%d) \n', N, acc1_bi*100, int32(acc1_bi*total), total);
                fprintf('Accuracy %d-Grams (Sub): %.2f %% (%d/%d) \n', N, acc2*100, int32(acc2*total), total);
                
                
                disp('%%%%%%%%%%%%%%%%% NB-SVM %%%%%%%%%%%%%%%%%%%');
                fprintf('Accuracy %d-Grams (Orig): %.2f %% (%d/%d) \n', N, acc1_bi_svm*100, int32(acc1_bi_svm*total), total);                
                fprintf('Accuracy %d-Grams (Sub): %.2f %% (%d/%d) \n', N, acc2_svm*100, int32(acc2_svm*total), total);
                
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
                mean(vocSizeSubs_n(:,li)), ...
                mean(accuracies2_n_nb(:,li)), ...
                std(accuracies2_n_nb(:,li)), ...
                mean(p2_n(:,li)),...
                mean(accuracies2_n_svm(:,li)), ...
                std(accuracies2_n_svm(:,li))};
        end
        
        all_results{lj} = results;
    end
    all_results_t = [all_results_t; cell2table(vertcat(all_results{:}),'VariableNames', results_fields)];
    all_accs_t = all_results_t(:,[1:6 all_accs_t_fields']);
end
save(sprintf('business-signal-%d-ngrams.mat',lk), 'all_results_t', 'all_accs_t');
