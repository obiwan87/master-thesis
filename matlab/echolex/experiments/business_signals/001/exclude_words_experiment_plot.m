% h = figure;
%
% for i = 1:numel(R1.Sessions)
%     session = R1.Sessions{i};
%     report = session.Report;
%
%     lfgosses = [losses.Out];
%     losses = [losses.loss];
%
%     losses = losses(1:end);
%
%     subplot(ceil(sqrt(numel(R.Sessions))), ceil(sqrt(numel(R.Sessions))),i);
%     plot(1-losses, '.-');
%     xlabel('n / Min. Frequency of Words');
%     ylabel('Classification Accuracy');
%     title(session.Name);
%
% end

% Retrieves classification loss for each dataset and combination of "exclude
% words".
query = '[{$match:{ExperimentId:1}},{$unwind:{path:"$Steps"}},{$project:{_id:0,loss:"$Steps.Out.loss",minCount:{$cond:{if:{$lte:[{$size:"$Steps.Args.mincount"},0]},then:1,else:"$Steps.Args.mincount"}},vocAfter:{$cond:{if:{$lte:[{$size:"$Steps.vocAfter"},0]},then:1,else:"$Steps.vocAfter"}},Dataset:1}},{$unwind:{path:"$loss"}},{$unwind:{path:"$minCount"}},{$unwind:{path:"$vocAfter"}},{$group:{_id:{dataset:"$Dataset"},losses:{$push:"$loss"},mincounts:{$push:"$minCount"},vocAfter:{$push:"$vocAfter"}}},{$project:{dataset:"$_id.dataset",losses:1,mincounts:1,vocAfter:1,_id:0}},{$sort:{dataset:1}}]';
results = store.aggregate(query);

figure;
hold on
n = numel(results);

for i=1:n
    subplot(ceil(sqrt(n)), ceil(sqrt(n)), i);
    result = results(i);
    plot(result.mincounts, result.losses);
    xlabel('Min. Word Frequency')
    ylabel('Loss');
    
    title(result.dataset);
end
p = {};

% Create combinations of exclude words
g = pgrid('ExcludeWords', 'MinCount', 1:5, 'MaxCount', Inf);

p{end+1} = fork(g); %#ok<*SAGROW>
p{end+1} = TfIdf();
p{end+1} = SVMClassifier('KFold', 10);
P = pipeline(p);
figure;
plot(P);
