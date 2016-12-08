import com.mongodb.*
import com.mongodb.util.*

if ~exist('mongoClient', 'var')
    mongoClient = MongoClient();
    db = mongoClient.getDB( 'test' );
end

coll = db.getCollection('testCollection');
docs = coll.find();

while docs.hasNext()
    doc = docs.next();
    jsonString = char(doc.toString());
    s = loadjson(jsonString);
    s
end