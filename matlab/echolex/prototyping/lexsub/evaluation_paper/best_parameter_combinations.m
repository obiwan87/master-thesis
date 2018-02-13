groups = findgroups(results(:,1:2));
g = unique(groups);
nbest = 1:3;
best_results = [];
for i=1:numel(g)
    idx = groups == g(i);
    r = results(idx,:);
    
    r = sortrows(r, {'mean_acc_sub_n_svm'}, {'descend'});
   
    if isempty(best_results)
        best_results = r(nbest,:);
    else
        best_results = [best_results; r(nbest,:)];
    end
end
