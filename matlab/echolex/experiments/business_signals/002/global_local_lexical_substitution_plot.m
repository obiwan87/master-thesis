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
        
        % Bar Graph of losses with GKLS
        idxs = (3*(j-1) + 1):3*j;
        losses = s.loss(idxs,:)';
        k = s.k(idxs,:);
        bar(losses);
        ax = gca;
        ax.YLim = [0 0.3];
        ax.XTick = 1:numel(unique(k));
        ax.XTickLabel = unique(k);
        ax.XLim = [0 numel(unique(k))+1];
        % Line Plots of losses without LexSub
        for k=1:numel(features)
            plot(ax.XLim, [ns.loss(k) ns.loss(k)]);
        end
        xlabel('K / Nearest Neighbors');
        ylabel('Loss');
        
        dataset = s.dataset{j};
        dataset(1) = upper(dataset(1));
        title(dataset);
        if j==numel(s.dataset)
            legend({features{:} features{:}});
        end
    end
end

p = sequence(  ...
    select(@(s) mini(cellfun(@(y) y.Out.loss, s)), ...
    sequence(fork(grid('ExcludeWords', 'MinCount', num2cell(1:3), 'MaxCount', {Inf})), ...
    TfIdf(), ...
    SVMClassifier('KFold', 10) )), ...
    fork(nop(), ...
    sequence(LocalLexicalKnnSubstitution('K', 10, 'MaxIter', 10, 'DictDeltaThresh', 10), nop()), ...
    sequence( ...
    fork(grid('GlobalLexicalKnnSubstitution', 'K', num2cell([150, 100, 50, 30, 20]), 'sigma', {@(x,y,z) (x+y), @(x,y,z) (x+y)./exp(1.3*z)})), ...
    fork(nop(),LocalLexicalKnnSubstitution('K', 10, 'MaxIter', 10, 'DictDeltaThresh', 10)))), ...
    fork(TfIdf(), WordCountMatrix(), TfIdfVectorizer()), ...
    SVMClassifier('CrossvalParams', {'KFold', 10}));

h = figure;
h.Name = 'Global/Lexical  KNN-Substitution';

P = pipeline(p);
plot(P);
