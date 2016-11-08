classdef DocumentSet < handle
    %DOCUMENT Represents a set of documents and provides handy statistics 
    %   Reads a textfile, where each line represents a document and each
    %   document is consists of set of words delimited by ' '.
    
    properties
        Filename
        T
        V = []
        I
    end
    
    methods
        function obj = DocumentSet(filename)
            obj.Filename = filename;
            obj.read()
        end
        
        function terms2Indexes(obj)            
            if isempty(obj.V)
                extractVocabulary();
            end
            
            obj.I = cellfun(@(x) cellfun(@(y) find(strcmp(y,obj.V)), x), obj.T, 'UniformOutput', false);
        end
        
        function tfidfs(obj)            
            error('Not Implemented');
        end
        
        function F = termFrequencies(obj)
            if isempty(obj.V)
                obj.extractVocabulary()
            end
            
            F = func.foldr(obj.T, [], @(x,y) [x y]);
            F = cellfun(@(x) sum(strcmp(x,F)), obj.V);
            F = table(obj.V, F, 'VariableNames', {'Term', 'Frequency'});
        end
        
        function V = extractVocabulary(obj)
            V = func.foldr(obj.T, [], @(x,y) [x y]);
            V = unique(V)';
            obj.V = V;
        end
    end
    
    methods(Access=private)
        function read(obj)
            obj.T = readtable(obj.Filename, 'ReadVariableNames', false);
            obj.T = cellfun(@(x) strsplit(x), obj.T.Var1, 'UniformOutput', false);
            
            if size(obj.T, 1) < size(obj.T, 2)
                obj.T = obj.T';
            end
        end        
    end
    
end

