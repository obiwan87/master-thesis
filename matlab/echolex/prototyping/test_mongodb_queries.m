coll = db.getCollection('testCollection');

query = dbobject('{ info: {$exists: true } }');
projection = dbobject('{info.description: 1}');

docs = coll.find(query, projection);
while docs.hasNext()
    doc = docs.next();
    jsonString = char(doc.toString());    
    s = loadjson(jsonString);
    s
end

disp('Aggregation');

%Aggregation
match = dbobject('{$match : { color: "blue", info: {$exists: true} } }}');
project = dbobject('{$project:  {_id: 0, description: "$info.description" } }');
p = java.util.ArrayList();
p.add(match);
p.add(project);

docs = coll.aggregate(p).results();

for i = 1:docs.size()
    doc = docs.get(i-1);
    jsonString = char(doc.toString());    
    s = loadjson(jsonString);
    s
end

s = '{exp: 1, session: "test", steps: [ [{n: [1,1]}, {n: [1,2]} ], [{n: [2,1]}, {n: [2,2]} ], [{n: [3,1]}, {n: [3,2]} ] ] }';
doc = dbobject(s);
coll.insert(doc,wc);