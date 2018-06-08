best_results_to_dataset = zeros(size(best_results,1),1);
for j=1:size(best_results, 1)   
    best_result = best_results(j,:);
    datasetName = sprintf('%s-%d-%d', best_result.DatasetName{1}, best_result.holdout, best_result.Run);
    i = strcmp(datasetNames, datasetName);
    
    if ~any(i)
        continue;
    end
    best_results_to_dataset(j) = find(i);
end