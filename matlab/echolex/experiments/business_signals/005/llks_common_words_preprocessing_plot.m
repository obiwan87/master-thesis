% db.getCollection('experiments').aggregate
%(
% [
%     {$match: {ExperimentId: 5}},
%     {$unwind: "$Steps"},
%     {$match: { "Steps.Name": {$in: ["LocalLexicalKnnSubstitution"] }} },
%     {$project: { LVi: "$Steps.LVi", k: "$Steps.Args.k"}}
% ]
% )

query = '[{$match:{ExperimentId:5}},{$unwind:"$Steps"},{$match:{"Steps.Name":{$in:["LocalLexicalKnnSubstitution"]}}},{$project:{LVi:"$Steps.LVi",k:"$Steps.Args.k"}}]';
query = '[{$match:{ExperimentId:5}},{$unwind:"$Steps"},{$project:{accuracy:"$Steps.Out.accuracy",name:"$Steps.Name",k:"$Steps.Args.k",_id:0,vocSizeAfter:"$Steps.vocSizeAfter"}},{$unwind:"$accuracy"}]';

results = store.aggregate(query);
save('results.mat', 'results');
for i=1:numel(results)
    r = results(i);
    LVi = [(1:size(r.LVi,1))' r.LVi];
    F = histc(LVi(:), unique(LVi));
    S = [LVi F];
    S = sortrows(S, size(S,2));
    
    C = W.V(flatten(S(:,1:end-1)));
    C = reshape(C, size(S,1),size(S,2)-1);
end

