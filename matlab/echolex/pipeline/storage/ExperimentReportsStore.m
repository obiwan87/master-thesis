classdef ExperimentReportsStore
    %EXPERIMENTSSTORE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Access=public)
        Client
        Collection
        Db
    end
    
    methods
        function obj = ExperimentReportsStore(database, collection)
            obj.Client = com.mongodb.MongoClient();
            obj.Db = obj.Client.getDB(database);
            obj.Collection = obj.Db.getCollection(collection);
        end
        
        function add(obj, experimentReport)
            jsonString = savejson('', experimentReport);
            dbo = dbobject(jsonString);
            wc = com.mongodb.WriteConcern(1);
            obj.Collection.insert(dbo, wc);
        end
        
        function results = get(obj, experimentId)
            queryString = sprintf('{ ExperimentId: %d }', experimentId);
            suppressIdQuery = '{_id: 0 }';
            results = obj.find(query, projection);
            
            for i=1:numel(results)
                results{i} = ExperimentReport.fromStruct(results{i});
            end
        end
        
        function results = find(obj, query, projection)
            
            query = dbobject(query);
            projection = dbobject(projection);
            cursor = obj.Collection.find(query, projection);
            results = cell(cursor.size(), 1);
            
            k = 1;
            while cursor.hasNext()
                document = cursor.next();
                jsonString = char(document.toString());
                results{k} =loadjson(jsonString);
                k = k + 1;
            end
            
            if numel(results) == 1
                results = results{1};
            else
                results = [results{:}];
            end
        end
        
        function results = aggregate(obj, query)
            dbo = dbobject(query);            
            p = java.util.ArrayList();
            
            it = dbo.iterator();
            
            while it.hasNext()
                o = it.next();
                p.add(o);
            end
            
            aggResults = obj.Collection.aggregate(p).results();
            results = cell(aggResults.size(),1);
            for i=1:aggResults.size()
                jsonString = char(aggResults.get(i-1).toString());
                results{i} = loadjson(jsonString);
            end
            
            if numel(results) == 1
                results = results{1};
            else
                results = [results{:}];
            end
        end
    end
    
end
