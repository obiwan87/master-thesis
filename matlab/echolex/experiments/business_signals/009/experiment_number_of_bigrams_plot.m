query_base = '[{$match:{ExperimentId:9}},{$unwind:"$Steps"},{$project:{method:{$arrayElemAt:["$Steps.Name",0]},dataset:"$Dataset",accuracy:"$Steps.Out.accuracy",classifier:{$arrayElemAt:["$Steps.Name",-1]}}},{$unwind:"$accuracy"},{$match:{method:"NoOperation"}},{$project:{accuracy:1,classifier:1,dataset:1,_id:0}},{$group:{_id:{classifier:"$classifier"},accuracy:{$push:"$accuracy"},dataset:{$push:"$dataset"}}},{$sort:{dataset:1, "_id.classifier":1}}]';
query = fileread('009_query.json');

results_base = store.aggregate(query_base);
results = store.aggregate(query);

for i=1:numel(results)
    fig = figure;
    fig.Name = results(i).x0x5F_id.classifier;
    nbest = results(i).nbest;
    num_combinations = numel(results(i).keepUnigrams);
    num_datasets = numel(results(i).accuracies)/(num_combinations*numel(nbest));
    accuracies = results(i).accuracies;    
    datasets = results(i).dataset{1};
    %datasets = {'erweiterung'};
    
    for k=1:numel(datasets)
        legend_strs = cell(num_combinations+1,1);
        
        subplot(ceil(sqrt(numel(datasets))),ceil(sqrt(numel(datasets))), k);
        for j=1:num_combinations
            row = (j-1)*numel(datasets) + k;
            keepUnigrams = results(i).keepUnigrams(j);
            scoreFcn = results(i).scoreFcn{j};    
            
            hold on
            plot(nbest, accuracies(row,:));
            hold off
            legend_strs{j} = sprintf('Unigrams: %d, ScoreFcn: %s', keepUnigrams, scoreFcn);
            
        end
        hold on
        ax = gca;
        plot(ax.XLim, [ results_base(i).accuracy(k) results_base(i).accuracy(k)]); 
        
        title(datasets{k});
        legend_strs{end} = 'Nop';
        legend(legend_strs, 'Interpreter', 'none');
    end    
end

