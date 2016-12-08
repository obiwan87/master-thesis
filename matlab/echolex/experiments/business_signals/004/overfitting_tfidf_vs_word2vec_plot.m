% db.getCollection('experiments').aggregate(
% [
% {$match: { ExperimentId: 4}},
% {$unwind: "$Steps"},
% {$project: {loss: "$Steps.Out.loss", mincount: "$Steps.Args.mincount", name: "$Steps.Name"}},
% {$unwind: "$name"},
% {$match: {name: {$in: ["TfIdf", "TfIdfVectorizer" ] }}},
% {$unwind: "$loss"},
% {$unwind: "$mincount"},
% {$group: {_id: { name: "$name" }, loss: {$push: "$loss" }, mincount: {$push: "$mincount"}}},
% {$project: {_id: 0, name: "$_id.name", loss:1, mincount: 1}}
% ]
% )