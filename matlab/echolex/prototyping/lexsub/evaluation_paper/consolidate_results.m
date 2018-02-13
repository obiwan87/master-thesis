d = dir(fullfile(echolex_results, 'public-datasets'));

results = [];
for i=1:numel(d)
    if d(i).isdir
        continue;
    end
    
    if endsWith(d(i).name, '.mat')
        filename = fullfile(d(i).folder, d(i).name);
        load(filename);
        
        f = strsplit(d(i).name, '-');
        if numel(f) > 2
            datasetName = f{2};
            datasetName = cellstr(repmat(datasetName, size(all_results_t, 1), 1));
            datasetNameTable = cell2table(datasetName, 'VariableNames', {'DatasetName'});
            all_results_t = [datasetNameTable all_results_t];
            
            if isempty(results)
                results = all_results_t;
            else
                
                results = [results; all_results_t];
            end
        end
    end
end