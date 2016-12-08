llks_query = '[{$match:{ExperimentId:3}},{$unwind:"$Steps"},{$match:{"Steps.Name":{$in:["LocalLexicalKnnSubstitution"]}}},{$project:{loss:"$Steps.Out.loss",k:"$Steps.Args.k",holdout:"$Steps.Args.svmparams",dataset:"$Dataset"}},{$unwind:"$holdout"},{$unwind:{path:"$holdout",includeArrayIndex:"idx"}},{$unwind:"$loss"},{$unwind:"$k"},{$match:{"idx":1}},{$project:{"_id":0,k:1,loss:1,holdout:1,dataset:1}},{$group:{_id:{dataset:"$dataset"},loss:{$push:"$loss"},k:{$push:"$k"},holdout:{$push:"$holdout"}}}]';
nop_query = '[{$match:{ExperimentId:3}},{$unwind:"$Steps"},{$match:{"Steps.Name":{$nin:["LocalLexicalKnnSubstitution"]}}},{$project:{loss:"$Steps.Out.loss",holdout:"$Steps.Args.svmparams",dataset:"$Dataset"}},{$unwind:"$holdout"},{$unwind:{path:"$holdout",includeArrayIndex:"idx"}},{$unwind:"$loss"},{$match:{"idx":1}},{$project:{"_id":0,loss:1,holdout:1,dataset:1}},{$group:{_id:{dataset:"$dataset"},loss:{$push:"$loss"},holdout:{$push:"$holdout"}}}]';
llks_results = store.aggregate(llks_query);
nop_results = store.aggregate(nop_query);

for i=1:numel(llks_results)
    l = llks_results(i);
    llks_loss = llks_results(i).loss;
    nop_loss = nop_results(i).loss;
    loss = [nop_loss llks_loss];
    loss = reshape(loss, numel(unique(l.k))+1,numel(unique(l.holdout)));
    %loss = softmax(loss);
    figure;
    [X,Y] = ndgrid([0 unique(l.k)], unique(l.holdout));
    %[X,Y] = meshgrid([0 unique(l.k)], unique(l.holdout));
    F = griddedInterpolant(X,Y,loss,'linear');
    [Xq, Yq] = ndgrid(0:1:30, 0.7:0.01:0.9);
    Vq = F(Xq,Yq);
    %surfc(X, Y, loss'); 
    surfc(Xq, Yq, Vq); 
    title(l.x0x5F_id.dataset);
    xlabel('K / Nearest Neighbors');
    ylabel('Holdout');
    zlabel('Classification Loss');
    colormap jet
    colorbar    
    view(2);
    shading('faceted');
end