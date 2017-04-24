%query = '[{$match:{ExperimentId:10}},{$unwind:"$Steps"},{$project:{method:{$arrayElemAt:["$Steps.Name",0]},accuracy:"$Steps.Out.accuracy",holdout:{$arrayElemAt:["$Steps.Args.crossvalparams",0]},bigrams:{$arrayElemAt:["$Steps.Args.nbest",0]}}},{$project:{method:1,accuracy:1,holdout:{$arrayElemAt:["$holdout",1]},bigrams:1,_id:0}},{$unwind:"$accuracy"},{$sort:{bigrams:1,holdout:1}},{$group:{_id:{holdout:"$holdout",method:"$method"},accuracy:{$push:"$accuracy"},bigrams:{$push:"$bigrams"}}},{$sort:{"_id.holdout":1,"_id.method":1}}]';
query ='[{$match:{ExperimentId:101}},{$unwind:"$Steps"},{$project:{dataset:"$Dataset",classifier:{$arrayElemAt:["$Steps.Name",-1]},method:{$arrayElemAt:["$Steps.Name",0]},accuracy:"$Steps.Out.accuracy",holdout:{$arrayElemAt:["$Steps.Args.crossvalparams",0]},bigrams:{$arrayElemAt:["$Steps.Args.nbest",0]}}},{$project:{dataset:1,classifier:1,method:1,accuracy:1,holdout:{$arrayElemAt:["$holdout",1]},bigrams:1,_id:0}},{$unwind:"$accuracy"},{$sort:{bigrams:1,holdout:1}},{$group:{_id:{holdout:"$holdout",method:"$method",classifier:"$classifier",dataset:"$dataset"},accuracy:{$push:"$accuracy"},bigrams:{$push:"$bigrams"}}},{$sort:{"_id.classifier":1,"_id.dataset":1,"_id.holdout":1,"_id.method":1}},{$match:{"_id.dataset":"%s","_id.classifier":"%s"}}]';
classifier = 'NaiveBayesClassifier';
dataset = 'erweiterung';
results = store.aggregate(sprintf(query, dataset, classifier));
grid_size = ceil(sqrt(numel(results)/2));


datasets = {'erweiterung', 'fuehrungswechsel'};
classifiers = {'SVMClassifier', 'NaiveBayesClassifier'};
C = allcomb(datasets, classifiers);


for k=1:size(C,1)    
    dataset = C{k, 1};  
    classifier = C{k,2};            
    
    results = store.aggregate(sprintf(query, dataset, classifier));
    fig = figure;    
    fig.Name = sprintf('%s - %s', dataset, classifier);
    for i = 1:numel(results)/2
        j = (i-1)*2 + 1;
        
        subplot(grid_size,grid_size,i);
        plot(results(j).bigrams, results(j).accuracy*100);
        hold on
        plot(results(j+1).bigrams, results(j+1).accuracy*100);
        title(sprintf('Holdout: %d %%', results(j).x0x5F_id.holdout*100));
        xlabel('#Bigrams');
        ylabel('Accuracy / %');
    end
    
    legend('LLKS', 'NOP');
end