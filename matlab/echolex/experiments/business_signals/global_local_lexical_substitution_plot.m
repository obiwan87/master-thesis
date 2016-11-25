globalLexSubQuery = '[{$match:{ExperimentId:2}},{$unwind:{path:"$Steps"}},{$match:{"Steps.Name":{$nin:["LocalLexicalKnnSubstitution"]}}},{$project:{_id:0,loss:"$Steps.Out.loss",dataset:"$Dataset",Steps:1,sigma:"$Steps.Args.sigma",k:"$Steps.Args.k"}},{$unwind:{path:"$loss"}},{$unwind:{path:"$sigma"}},{$unwind:{path:"$k"}},{$group:{_id:{dataset:"$dataset",sigma:"$sigma"},losses:{$push:"$loss"},k:{$push:"$k"}}},{$project:{_id:0,dataset:"$_id.dataset",sigma:"$_id.sigma",losses:1,k:1}},{$sort:{dataset:1,sigma:1}}]';
noPreprocessingQuery = '[{$match:{ExperimentId:2}},{$unwind:{path:"$Steps"}},{$match:{"Steps.Name":{$nin:["LocalLexicalKnnSubstitution","GlobalLexicalKnnSubstitution"]}}},{$project:{loss:"$Steps.Out.loss",dataset:"$Dataset"}},{$unwind:{path:"$loss"}}]';

globalLexSubResults = store.aggregate(globalLexSubQuery);
noPreprocessingResults = store.aggregate(noPreprocessingQuery);

sigmas = unique({globalLexSubResults.sigma});

for i=1:numel(sigmas)
    sigma = sigmas{i};
    
    gs = globalLexSubResults(strcmp(sigma, {globalLexSubResults.sigma}));
    
    figure;
    n = numel(gs);
    for j=1:numel(gs)        
        result = gs(j);
        ii = strcmp(gs(j).dataset, {noPreprocessingResults.dataset});        
        ns = noPreprocessingResults(ii);
        
        subplot(ceil(sqrt(n)), ceil(sqrt(n)), j);
        
        [K, ii] = sort(result.k);
        losses = result.losses;
        losses = losses(ii);
                
        plot(K, losses);
        hold on
        ax = gca;
        plot(ax.XLim, [ns.loss ns.loss]);
        ylabel('Loss');
        xlabel('K / Nearest Neighbors');
        title(result.dataset);
    end
end