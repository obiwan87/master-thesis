import com.mongodb.*
import com.mongodb.util.*

if ~exist('mongoClient', 'var')
mongoClient = MongoClient();
db = mongoClient.getDB( 'test' );
end

s = struct('color', {'blue', 'red', 'blue'}, 'shape', {'circle', 'square', 'triangle'}, 'vertices', {Inf, 4, 3}, 'info', {struct('description', 'round object', 'area', 'pi*r^2'), struct('description', 'square object', 'area', 'a^2'), struct('description', 'square object', 'area', 'c*h/2')});
jsonString = savejson('', s);

doc = com.mongodb.util.JSON.parse(jsonString);
coll = db.getCollection('testCollection');
wc = com.mongodb.WriteConcern(1);

coll.insert(doc)