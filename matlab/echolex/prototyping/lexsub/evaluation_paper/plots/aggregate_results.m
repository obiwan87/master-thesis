groups = findgroups(test_results(:,1:2));

nb = splitapply(@aggr,test_results.accNb, test_results.subAccNb, groups);
nbsvm = splitapply(@aggr,test_results.accNbSvm, test_results.subAccNbSvm, groups);
rae = splitapply(@aggr,test_results.accRae, test_results.subAccRae, groups);

classifiers = {'nb', 'nbsvm', 'rae'};
prefixes = {'' , 'sub_', 'delta_'};
aggfunctions = {'min_', 'max_', 'mean_'};


fieldnames = {};
for i=1:numel(classifiers)
    for j=1:numel(prefixes)
        for k =1:numel(aggfunctions)
            fieldnames{end+1} = strcat(aggfunctions{k}, prefixes{j}, classifiers{i});
        end
    end
end

aggregated_results = [nb nbsvm rae];
aggregated_results = array2table(aggregated_results, 'VariableNames', fieldnames);
aggregated_results = [test_results(1:5:end, 1:2) aggregated_results];

deltas_results = aggregated_results(:,[1:2 9:11 18:20 27:29]);

function g = aggr(acc, subAcc)
    minAcc = min(acc);
    maxAcc = max(acc);
    meanAcc = mean(acc);    
    
    maxSubAcc = max(subAcc);
    meanSubAcc = mean(subAcc);
    minSubAcc = min(subAcc);
    
    deltaAcc = subAcc - acc;
    meanDeltaAcc = mean(deltaAcc);
    minDeltaAcc = min(deltaAcc);
    maxDeltaAcc = max(deltaAcc);
        
    g = [minAcc maxAcc meanAcc minSubAcc maxSubAcc meanSubAcc minDeltaAcc maxDeltaAcc meanDeltaAcc];
end