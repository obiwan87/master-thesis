query = '[{$unwind: { path: "$Steps" }}, {$match: { "Steps.Name": "GlobalLexicalKnnSubstitution" }}, {$project: {_id:0 , steps: "$Steps" ,loss: "$Steps.Out.loss"}},{$unwind: {path: "$steps" } },{$match: { "steps.Name": "GlobalLexicalKnnSubstitution" }},{$unwind: { path: "$loss" }},{$project: {args: "$steps.Args", loss: 1 }},{$group: {_id: { sigma: "$args.sigma" }, loss: {$avg: "$loss" } } }]';
dbo = dbobject(query);

p = java.util.ArrayList();

it = dbo.iterator();

while it.hasNext()
    o = it.next();
    p.add(o);
end

agg = store.Collection.aggregate(p);
