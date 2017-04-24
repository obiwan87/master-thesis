query = '[{$match:{ExperimentId:11,Dataset:"fuehrungswechsel"}},{$unwind:"$Steps"},{$project:{accuracy:{$arrayElemAt:["$Steps.Out.accuracy",0]},nbest:{$arrayElemAt:["$Steps.Args.nbest",0]},holdout:{$arrayElemAt:["$Steps.Args.crossvalparams",0]},mincount:{$arrayElemAt:["$Steps.Args.mincount",0]}}},{$project:{accuracy:1,nbest:1,holdout:{$arrayElemAt:["$holdout",1]},mincount:1}},{$match:{holdout:{$gte:0.1},mincount:2}},{$group:{_id:{holdout:"$holdout"},nbest:{$push:"$nbest"},accuracy:{$push:"$accuracy"}}},{$project:{_id:0,holdout:"$_id.holdout",nbest:1,accuracy:1}},{$sort:{holdout:1}}]';
query2 = '[{$match:{ExperimentId:12,Dataset:"fuehrungswechsel"}},{$unwind:"$Steps"},{$project:{accuracy:{$arrayElemAt:["$Steps.Out.accuracy",0]},substThresh:{$arrayElemAt:["$Steps.Args.substitutionthreshold",0]},nbest:{$arrayElemAt:["$Steps.Args.nbest",0]},maxIter:{$arrayElemAt:["$Steps.Args.maxiter",0]},holdout:{$arrayElemAt:["$Steps.Args.crossvalparams",0]},vocSizeBeforeEW:{$arrayElemAt:["$Steps.vocSizeBeforeEW",0]},vocSizeAfterEW:{$arrayElemAt:["$Steps.vocSizeAfterEW",0]},vocSizeBeforePS:{$arrayElemAt:["$Steps.vocSizeBeforePS",0]},vocSizeAfterPS:{$arrayElemAt:["$Steps.vocSizeAfterPS",0]},mincount:{$arrayElemAt:["$Steps.Args.mincount",0]},minSimilarity:{$arrayElemAt:["$Steps.Args.minsimilarity",0]},k:{$arrayElemAt:["$Steps.Args.k",0]}}},{$project:{accuracy:1,substThresh:1,nbest:1,maxIter:1,vocSizeBeforeEW:1,vocSizeAfterEW:1,vocSizeBeforePS:1,vocSizeAfterPS:1,k:1,mincount:1,minSimilarity:1,holdout:{$arrayElemAt:["$holdout",1]}}},{$match:{holdout:{$gte:0.1},mincount:2,k:5,maxIter:1,substThresh:20}},{$sort:{holdout:1,nbest:1}},{$group:{_id:{holdout:"$holdout",substThresh:"$substThresh",maxIter:"$maxIter",k:"$k",minSimilarity:"$minSimilarity"},nbest:{$push:"$nbest"},accuracy:{$push:"$accuracy"},bestAccuracy:{$max:"$accuracy"},vocSizeBeforePS:{$first:"$vocSizeBeforePS"},vocSizeAfterPS:{$first:"$vocSizeAfterPS"},}},{$sort:{holdout:1,bestAccuracy:-1}},{$project:{_id:0,data:{holdout:"$_id.holdout",substThresh:"$_id.substThresh",maxIter:"$_id.maxIter",k:"$_id.k",minSimilarity:"$_id.minSimilarity",accuracy:"$accuracy",nbest:"$nbest",bestAccuracy:"$bestAccuracy",vocSizeBeforePS:"$vocSizeBeforePS",vocSizeAfterPS:"$vocSizeAfterPS"}}},{$group:{_id:{holdout:"$data.holdout"},data:{$push:"$data"},bestAccuracy:{$max:"$data.bestAccuracy"}}},{$project:{_id:0,data:{$arrayElemAt:["$data",0]},bestAccuracy:1}},{$sort:{"data.holdout":1}}]';
query3 = '[{$match:{ExperimentId:102}},{$unwind:"$Steps"},{$project:{accuracy:{$arrayElemAt:["$Steps.Out.accuracy",0]},holdout:{$arrayElemAt:["$Steps.Args.crossvalparams",0]},nbest:{$arrayElemAt:["$Steps.Args.nbest",0]},}},{$project:{accuracy:1,nbest:1,holdout:{$arrayElemAt:["$holdout",1]}}},{$sort:{holdout:1,nbest:1}},{$group:{_id:{holdout:"$holdout"},accuracy:{$push:"$accuracy"},nbest:{$push:"$nbest"}}},{$project:{holdout:"$_id.holdout",accuracy:1,nbest:1}},{$sort:{holdout:1}}]';
query4 = '[{$match:{ExperimentId:103}},{$unwind:"$Steps"},{$project:{accuracy:{$arrayElemAt:["$Steps.Out.accuracy",0]},holdout:{$arrayElemAt:["$Steps.Args.crossvalparams",0]},nbest:{$arrayElemAt:["$Steps.Args.nbest",0]},}},{$project:{accuracy:1,nbest:1,holdout:{$arrayElemAt:["$holdout",1]}}},{$sort:{holdout:1,nbest:1}},{$group:{_id:{holdout:"$holdout"},accuracy:{$push:"$accuracy"},nbest:{$push:"$nbest"}}},{$project:{holdout:"$_id.holdout",accuracy:1,nbest:1}},{$sort:{holdout:1}}]';

%query2 = '[{$match:{ExperimentId:125,Dataset:"fuehrungswechsel"}},{$unwind:"$Steps"},{$project:{accuracy:{$arrayElemAt:["$Steps.Out.accuracy",0]},substThresh:{$arrayElemAt:["$Steps.Args.substitutionthreshold",0]},nbest:{$arrayElemAt:["$Steps.Args.nbest",0]},maxIter:{$arrayElemAt:["$Steps.Args.maxiter",0]},holdout:{$arrayElemAt:["$Steps.Args.crossvalparams",0]},vocSizeBeforeEW:{$arrayElemAt:["$Steps.vocSizeBeforeEW",0]},vocSizeAfterEW:{$arrayElemAt:["$Steps.vocSizeAfterEW",0]},vocSizeBeforePS:{$arrayElemAt:["$Steps.vocSizeBeforePS",0]},vocSizeAfterPS:{$arrayElemAt:["$Steps.vocSizeAfterPS",0]},mincount:{$arrayElemAt:["$Steps.Args.mincount",0]},k:{$arrayElemAt:["$Steps.Args.k",0]}}},{$project:{accuracy:1,substThresh:1,nbest:1,maxIter:1,vocSizeBeforeEW:1,vocSizeAfterEW:1,vocSizeBeforePS:1,vocSizeAfterPS:1,k:1,mincount:1,holdout:{$arrayElemAt:["$holdout",1]}}},{$match:{mincount:2}},{$group:{_id:{holdout:"$holdout",substThresh:"$substThresh",maxIter:"$maxIter",k:"$k",},nbest:{$push:"$nbest"},accuracy:{$push:"$accuracy"},bestAccuracy:{$max:"$accuracy"},vocSizeBeforePS:{$first:"$vocSizeBeforePS"},vocSizeAfterPS:{$first:"$vocSizeAfterPS"},}},{$sort:{holdout:1,bestAccuracy:-1}},{$project:{_id:0,data:{holdout:"$_id.holdout",substThresh:"$_id.substThresh",maxIter:"$_id.maxIter",accuracy:"$accuracy",nbest:"$nbest",bestAccuracy:"$bestAccuracy",vocSizeBeforePS:"$vocSizeBeforePS",vocSizeAfterPS:"$vocSizeAfterPS"}}},{$group:{_id:{holdout:"$data.holdout"},data:{$push:"$data"},bestAccuracy:{$max:"$data.bestAccuracy"}}},{$project:{_id:0,data:{$arrayElemAt:["$data",0]},bestAccuracy:1}},{$sort:{"data.holdout":1}}]';

results = store.aggregate(query);
results2 = store.aggregate(query2);
results3 = store.aggregate(query3);
results4 = store.aggregate(query4);
n = ceil(sqrt(numel(results)));

data = [results2.data];
x = [0 300];
ymin = min([data.accuracy]);
ymax = max([results.accuracy]);

figure;
for i=1:numel(results)
   result = results(i);     
   result2 = results2(i);     
   result3 = results3(i);
   result4 = results4(i);
   subplot(n,n,i);
   
   plot(result.nbest, result.accuracy); 
   hold on
   plot(result4.nbest, result4.accuracy);
   hold on
   plot(result2.data.nbest, result2.data.accuracy);
   hold on
   plot(result3.nbest, result3.accuracy);
   
   title(sprintf('Training Set: %d %%', 100-result.holdout*100));   
   xlim(x);
   xlabel('#Bigrams');
   ylabel('Accuracy');
end

legend('No Substitutions', 'No Substitutions - Binary','Frequency-Distance', 'LLKS');