[
{ $match: {ExperimentId: 6}},
{ $unwind: "$Steps" },
{ $project: { classifier: {$arrayElemAt: ["$Steps.Name", -1] }, 
              preprocessor: {$arrayElemAt: ["$Steps.Name", 0] } , 
              dataset: "$Dataset",  
              loss: {$arrayElemAt: ["$Steps.Out.loss",0] },
              clargs: {$arrayElemAt: ["$Steps.Args.crossvalparams", -1]}
              }},          
{ $sort: { preprocessor: 1 , dataset: 1, holdout: 1 } },
{ $project: { classifier: 1, preprocessor: 1, dataset: 1, loss: 1, holdout: { $arrayElemAt: ["$clargs", 1] }} },
{ $group: { _id: { preprocessor: "$preprocessor", dataset: "$dataset"}, loss: {$push: "$loss"}, holdout: {$push: "$holdout" }}},
{ $sort: {"_id.preprocessor": 1, dataset: 1}},
{ $group: { _id: { dataset: "$_id.dataset"}, loss: {$push: "$loss"}, holdout: {$first: "$holdout" }, preprocessor: {$push: "$_id.preprocessor"}}},
{ $project: { _id:0 ,  preprocessor: 1, loss: 1, holdout: 1, clargs:1, dataset: "$_id.dataset"}},
{ $sort: { dataset: 1 } }
] 