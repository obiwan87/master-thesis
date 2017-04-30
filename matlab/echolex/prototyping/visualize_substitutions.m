% %% Prepare Dataset
% EW = Ws{2};
% EW.B = [];
% EW.findBigrams();
% ngramsEW = BigramFinder.generateAllNGrams(EW,2,true);
% ngramsEW.wordCountMatrix();
% ngramsEW.findBigrams();
% c = cvpartition(EW.Y, 'kfold', 10);
% trainingIdx = training(c,1);
% testIdx = test(c,1);
% 
% [trD_uni, teD_uni] =        EW.split(testIdx, trainingIdx);
% [trD_bi,  teD_bi ] = ngramsEW.split(testIdx, trainingIdx);
% 
% 
% %% Calculate metrics
% dist_u = calculate_unigrams_distances(trD_uni,false,false);
% pL_ = normalized_kld(trD_uni, true);
% 
% 
% %% Cluster on training data
% a = 0.2;
% cutoff = 0.2;
% linkag = 'complete';
% scoreFunction = @(pL_,dists,a,b) pL_*a + dists/2*b;
% clusters = pairwise_clustering(dist_u, pL_, 'Linkage', linkag, 'Cutoff', cutoff, 'ScoreFunction', scoreFunction, 'ScoreFunctionParam1', a, 'ScoreFunctionParam2', 1-a);
% 
% %% Visualize Clusters
% C = unique(clusters);
% clusterFreqs = histc(clusters, C);
% ii = sorti(clusterFreqs, 'descend');
% 
% F = trD_uni.termFrequencies();
% F = F(trD_uni.Vi~=0,:);
% 
% for i = 11:numel(ii)
%     F(clusters==C(ii(i)),:)
%     waitforbuttonpress
% end
% 
% %% Substitute unkwnown words
% [substitutionMap1, clusterWordMap, clusterWordMapVi] = apply_cluster_substitutions(trD_uni, clusters);
% sTrD = trD_uni.applySubstitution(substitutionMap1);
% 
maxDistance = 0.4;
methodNearestClusterAssignment = 'average';
[substitutionMap2, clusterAssignmentMap, unseenWords, nns, cdist] = nearest_cluster_substitution(teD_uni, trD_uni, clusters, clusterWordMapVi, 'Method', methodNearestClusterAssignment, 'MaxDistance', maxDistance);

%% Visualize unknown words substitutions 
keys = substitutionMap2.keys;
Forig = EW.termFrequencies();
for i=1:numel(unseenWords)
    %fprintf('%s -> %s \n', unseenWords{i}, substitutionMap2(unseenWords{i}));
    for j=1:5        
        Forig(EW.index_of(unseenWords{i}),:)
        c = nns(i,j);
        cdist(i,j)
        F(clusters==c,:)     
        w = waitforbuttonpress;
        if w ~= 0
            break;
        end
    end
end
        
%% Inspect differences in prediction
[acc1_uni_svm, ~, predictions_orig_uni_svm]= trainTestNBSVM(EW, trainingIdx, testIdx);
[acc1_bi_svm,~ , predictions_orig_bi_svm] = trainTestNBSVM(ngramsEW, trainingIdx, testIdx);

[acc2_uni_svm,~,predictions_sub_uni_svm] = trainTestNBSVM(sD_uni, trainingIdx, testIdx);
[acc2_bi_svm,~,predictions_sub_bi_svm] = trainTestNBSVM(sD_bi, trainingIdx, testIdx);

testIdx = find(testIdx);
different_predictions = testIdx(predictions_sub_bi_svm ~= predictions_orig_bi_svm);

for i=1:numel(different_predictions)
    fprintf('Original Label: %d \n', EW.Y(different_predictions(i)));
    fprintf('Predict Label (Orig): %d \n', predictions_orig_bi_svm(different_predictions(i)));
    fprintf('Predict Label (Sub): %d \n', predictions_sub_bi_svm(different_predictions(i)));
    
    T1 = string(ngramsEW.T{different_predictions(i)});    
    T2 = string(sD_bi.T{different_predictions(i)});    
    
end


