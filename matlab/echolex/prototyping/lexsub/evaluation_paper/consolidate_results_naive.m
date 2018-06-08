results = [];
for i=1:numel(d)
    if d(i).isdir
        continue;
    end
    
    if endsWith(d(i).name, '.mat')
        filename = fullfile(d(i).folder, d(i).name);
        f = strsplit(d(i).name, '-');
        if numel(f) >= 2
            load(filename);
            l = all_results_t.b == 0;
            all_results_t = all_results_t(l, :);
            
            datasetName = f{1};
            holdout = f{2};
            holdout = repmat(str2double(holdout), size(all_results_t,1),1);
            run = repmat(str2double(f{3}), size(all_results_t, 1), 1);
            datasetName = cellstr(repmat(datasetName, size(all_results_t, 1), 1));                        
            
            datasetNameTable = table(run, datasetName, 'VariableNames', {'Run', 'DatasetName'});
            all_results_t = [datasetNameTable all_results_t];
            all_results_t.holdout = holdout;
            
            [~, j] = max(harmmean([all_results_t.precision_sub_n_svm, all_results_t.recall_sub_n_svm],2));            
            all_results_t = all_results_t(j,:);
            
            if isempty(results)
                results = all_results_t;
            else
                results = [results; all_results_t];
            end
        end
    end
end