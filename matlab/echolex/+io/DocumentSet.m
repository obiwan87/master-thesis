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
        Y = []
    end
    
    methods
        function obj = DocumentSet(s, labels)
            if nargin < 2
                labels = [];
            end
            
            if ischar(s)
                obj.Filename = s;
                obj.read();
            elseif iscell(s)
                obj.T = s;
                e = cellfun(@(x) isempty(x), obj.T);
                if sum(e) > 0
                    warning('%d empty documents', sum(e));
                    obj.T = obj.T(~e);
                    obj.EmptyLines = find(e);
                end
            end
            
            obj.Y = labels;
            obj.Y(obj.EmptyLines) = [];
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
        
        function D = filter_vocabulary(obj, minf, maxf, keep_n)
            if nargin < 4
                keep_n = NaN;
            end
            
            F = obj.termFrequencies();
            s = F.Frequency >= minf & F.Frequency <= maxf;
            
            F = F(s,:);
            
            if ~isnan(keep_n) && ~isinf(keep_n)
                [~, ii] = sort(F.Frequency, 'descend');
                F = F(ii(1:keep_n),:);
            end
            
            ids = cellfun(@(x) find(strcmp(x, obj.V)), F.Term);
            %FT = cellfun(@(x) obj.V(x), fids, 'UniformOutput', false, 'ErrorHandler', @(x) fprintf('%d\n', x) );
            
            FT = cell(size(obj.T));
            numDocs = numel(obj.T);
            for i=1:numDocs
                w = arrayfun(@(x) sum(x==ids) > 0, obj.I{i});
                FT{i} = obj.T{i}(w);
            end
            D = obj.newFrom(FT);
        end
        
        function ED = keep_word_ids(obj, ids)
            EI = cellfun(@(s) s(arrayfun(@(w) any(w == ids), s)), obj.I, 'UniformOutput', false);
            ET = cellfun(@(s) obj.V(s)', EI, 'UniformOutput', false);
            ED = obj.newFrom(ET);
        end
        
        function ED = exlude_word_ids(obj, ids)
            EI = cellfun(@(s) s(arrayfun(@(w) ~any(w == ids), s)), obj.I, 'UniformOutput', false);
            ET = cellfun(@(s) obj.V(s)', EI, 'UniformOutput', false);
            ED = obj.newFrom(ET);
        end
        
        function f = frequency_of(obj, word)
            flat_ind = func.foldr(obj.I, [], @(x,y) [x y]);
            i = find(strcmp(word, obj.V));
            f = sum(i == flat_ind);
        end
        
        function i = index_of(obj, word)
            i = find(strcmp(word, obj.V));
        end
        
        function N = newFrom(obj, T)
            N = io.DocumentSet(T, obj.Y);
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