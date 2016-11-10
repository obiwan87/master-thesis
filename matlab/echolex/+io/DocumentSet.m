classdef DocumentSet < handle
    %DOCUMENT Represents a set of documents and provides handy statistics
    %   Reads a textfile, where each line represents a document and each
    %   document is consists of set of words delimited by ' '.
    
    properties
        Filename = '' % Source Filename
        T = [] % Documents
        V = [] % Vocabulary of Document Set
        I = [] % Document-Matrix with Words as indexes of V
        W = [] % Word-Count-Matrix
        TfIdf = []
        EmptyLines = [];
    end
    
    methods
        function obj = DocumentSet(s)
            if ischar(s)
                obj.Filename = s;
                obj.read();
            elseif iscell(s)
                obj.T = s;
            end
        end
        
        function I = terms2Indexes(obj)
            if isempty(obj.V)
                obj.extractVocabulary();
            end
            
            I = cellfun(@(x) cellfun(@(y) find(strcmp(y,obj.V)), x), obj.T, 'UniformOutput', false);
            obj.I = I;
        end
        
        function TfIdf = tfidf(obj)
            if isempty(obj.W)
                obj.wordCountMatrix();
            end
            TfIdf = features.tfidf(obj.W')';
            obj.TfIdf = TfIdf;
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
            e = cellfun(@isempty, V);
            V = V(~e);
            obj.V = V;
        end
        
        function W = wordCountMatrix(obj)
            if isempty(obj.I)
                obj.terms2Indexes();
            end
            numDocs = size(obj.T,1); % Number of documents
            vocSize = numel(obj.V); % Vocabulary Size
            
            W = sparse(numDocs,vocSize);
            for i=1:numDocs 
                d = obj.I{i};
                M = unique(d);
                C = arrayfun(@(x) sum(x==d), M);
                
                W(i,M) = C; %#ok<SPRIX>
            end
            
            obj.W = W;
        end
    end
    
    methods(Access=private)
        function read(obj)
            
            obj.T = {};
            
            fid = fopen(obj.Filename);
            tline = fgets(fid);
            k = 1;
            empty_lines = [];
            while ischar(tline)
                tline = strtrim(tline);
                if ~isempty(tline)
                    obj.T{end+1} = tline;
                else
                    warning('Empty line detected');
                    empty_lines = [empty_lines; k]; %#ok<AGROW>
                end
                tline = fgets(fid);
                k = k +1;
            end
            
            obj.T = cellfun(@(x) strsplit(x), obj.T, 'UniformOutput', false);
                        
            if size(obj.T, 1) < size(obj.T, 2)
                obj.T = obj.T';
            end
            
            obj.EmptyLines = empty_lines;
        end
    end
end