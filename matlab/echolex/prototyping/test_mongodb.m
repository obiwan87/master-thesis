import com.mongodb.*
import com.mongodb.util.*

if ~exist('mongoClient', 'var')
mongoClient = MongoClient();
db = mongoClient.getDB( 'test' );
end

s = struct('vector', 1:10, 'matrix', eye(3), 'string', 'hello_world');
jsonString = savejson('', s);

doc = com.mongodb.util.JSON.parse(jsonString);

coll = db.getCollection('testCollection');
wc = com.mongodb.WriteConcern(1);
coll.insert(doc, wc);

docs = coll.find();

while docs.hasNext()
    doc = docs.next();
    jsonString = char(doc.toString());
    s = loadjson(jsonString);
    s
end

docs.close();



