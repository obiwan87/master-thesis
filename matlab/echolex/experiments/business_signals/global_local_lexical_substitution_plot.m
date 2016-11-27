globalLexSubQuery = '[{$match:{ExperimentId:2}},{$unwind:{path:"$Steps"}},{$match:{"Steps.Name":{$nin:["LocalLexicalKnnSubstitution"],$in:["GlobalLexicalKnnSubstitution"]}}},{$project:{dataset:"$Dataset",loss:"$Steps.Out.Out.loss",steps:"$Steps.Name",k:"$Steps.Args.k",sigma:"$Steps.Args.sigma",size:{$size:"$Steps"}}},{$unwind:{path:"$steps",includeArrayIndex:"idx"}},{$project:{t:{$eq:[{$subtract:["$size",2]},"$idx"]},size:1,idx:1,steps:1,loss:1,k:1,dataset:1,sigma:1}},{$match:{t:true}},{$unwind:"$loss"},{$unwind:"$k"},{$unwind:"$sigma"},{$group:{_id:{dataset:"$dataset",steps:"$steps",sigma:"$sigma"},k:{$push:"$k"},loss:{$push:"$loss"}}},{$project:{_id:0,features:"$_id.steps",sigma:"$_id.sigma",dataset:"$_id.dataset",loss:1,k:1}},{$group:{_id:{dataset:"$dataset",sigma:"$sigma"},features:{$push:"$features"},k:{$push:"$k"},loss:{$push:"$loss"}}},{$project:{_id:0,sigma:"$_id.sigma",dataset:"$_id.dataset",loss:1,k:1,features:1}},{$sort:{dataset:1}},{$group:{_id:{sigma:"$sigma"},features:{$push:"$features"},k:{$push:"$k"},loss:{$push:"$loss"},dataset:{$push:"$dataset"}}},{$project:{_id:0,sigma:"$_id.sigma",dataset:1,loss:1,k:1,features:1}}]';
noPreprocessingQuery = '[{$match:{ExperimentId:2}},{$unwind:"$Steps"},{$match:{"Steps.Name":{$nin:["LocalLexicalKnnSubstitution","GlobalLexicalKnnSubstitution"]}}},{$project:{loss:"$Steps.Out.Out.loss",Dataset:1,steps:"$Steps.Name",size:{$size:"$Steps.Name"}}},{$unwind:"$loss"},{$unwind:{path:"$steps",includeArrayIndex:"idx"}},{$project:{t:{$eq:["$idx",{$subtract:["$size",2]}]},Dataset:1,steps:1,loss:1}},{$match:{t:true}},{$group:{_id:{dataset:"$Dataset"},features:{$push:"$steps"},loss:{$push:"$loss"}}},{$project:{_id:0,dataset:"$_id.dataset",features:1,loss:1}},{$sort:{dataset:1}}]';

globalLexSubResults = store.aggregate(globalLexSubQuery);
noPreprocessingResults = store.aggregate(noPreprocessingQuery);

for i=1:numel(globalLexSubResults)
    s = globalLexSubResults(i);
    sigma = s.sigma;
    N = numel(s.dataset);
    figure('name', sigma);
    for j=1:numel(s.dataset)
        features = s.features{j};
        ns = noPreprocessingResults(j);
        subplot(ceil(sqrt(N)), ceil(sqrt(N)), j);   
        hold on
        for k=1:numel(features)
            loss = s.loss(j*k,:);
            K = s.k(j*k,:);            
            plot(K, loss);
            ax = gca;
            ax.XLim = [min(K) max(K)];
            plot(ax.XLim, [ns.loss(k) ns.loss(k)]);
        end

        title(s.dataset{j});
        if j==numel(s.dataset)
            legend(features);
        end
    end
end

% sigmas = unique({globalLexSubResults.sigma});
% 
% for i=1:numel(sigmas)
%     sigma = sigmas{i};
%     
%     gs = globalLexSubResults(strcmp(sigma, {globalLexSubResults.sigma}));
%     
%     figure;
%     n = numel(gs);
%     for j=1:numel(gs)        
%         result = gs(j);
%         ii = strcmp(gs(j).dataset, {noPreprocessingResults.dataset});        
%         ns = noPreprocessingResults(ii);
%         
%         subplot(ceil(sqrt(n)), ceil(sqrt(n)), j);
%         
%         [K, ii] = sort(result.k);
%         losses = result.losses;
%         losses = losses(ii);
%                 
%         plot(K, losses);
%         hold on
%         ax = gca;
%         plot(ax.XLim, [ns.loss ns.loss]);
%         ylabel('Loss');
%         xlabel('K / Nearest Neighbors');
%         title(result.dataset);
%     end
% end