classdef DocumentSet < handle
    %DOCUMENT Represents a set of documents and provides handy statistics
    %   Reads a textfile, where each line represents a document and each
    %   document is consists of set of words delimited by ' '.
    
    properties
        Filename = '' % Source Filename
        DatasetName = ''; % Name of dataset
        T = [] % Documents
        V = [] % Vocabulary of Document Set
        I = [] % Document-Matrix with Words as indexes of V
        W = [] % Word-Count-Matrix
        B = [] % Bigrams: Indicates whether v \in V is a bigram
        F = [] % Term Frequencies
        TfIdf = []
        EmptyLines = [];
        Y = []
    end
    
    methods
        function obj = DocumentSet(s, labels, empty)
            if nargin < 2
                labels = [];
            end
            
            if nargin < 3
                empty = false;
            end
            
            if ~empty
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
        end
        
        function I = terms2Indexes(obj)
            if isempty(obj.V)
                obj.extractVocabulary();
            end
            
            map = containers.Map();
            
            for i=1:numel(obj.V)
                map(obj.V{i}) = i;
            end
            
            I = cellfun(@(x) cellfun(@(y) map(y), x), obj.T, 'UniformOutput', false);
            obj.I = I;
            
        end
        
        function prepare(obj)
            obj.tfidf();
            obj.findBigrams();
        end
        
        function B = findBigrams(obj)            
            bigrams_ = cellfun(@(x) strsplit(x, '_'), obj.V, 'UniformOutput', false);
            B = cellfun(@(x) numel(x), bigrams_);            
            obj.B = B;
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
            
            if isempty(obj.W)
                obj.wordCountMatrix();
            end
            
            w = obj.W;
            f = full(sum(w));
            w(w>0) = 1;
            d = full(sum(w));
            p = full(sum(w(obj.Y==1,:)));
            n = d - p;
            obj.F = table(obj.V, f', d', p', n', 'VariableNames', {'Term', 'Frequency', 'Docs', 'PDocs', 'NDocs'});
            F = obj.F;
        end
        
        function V = extractVocabulary(obj)
            V = func.foldr(obj.T, [], @(x,y) [x y]);
            V = unique(V)';
            e = cellfun(@isempty, V);
            V = V(~e);
            obj.V = V;
        end
        
        function L = termLabels(obj)
            if isempty(obj.I)
                obj.terms2Indexes();
            end
            
            C = unique(obj.Y);
            L = zeros(numel(obj.V), numel(C));
            for i=1:numel(C)
                c = C(i);
                samples = obj.I(obj.Y == c);
                t = unique(func.foldr(samples, [], @(x,y) [x y]));
                L(t,i) = 1;
            end
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
                C = histc(d,M);
                
                W(i,M) = C; %#ok<SPRIX>
            end
            
            obj.W = W;
        end
        
        function text = get_text(obj)
            text = strjoin(cellfun(@(x) strjoin(x, ' '), obj.T, 'UniformOutput', false), '\n');
        end
        
        function D = filter_vocabulary(obj, minf, maxf, keep_n)
            if nargin < 4
                keep_n = NaN;
            end
            
            Fr = obj.termFrequencies();
            s = Fr.Frequency >= minf & Fr.Frequency <= maxf;
            
            Fr = Fr(s,:);
            
            if ~isnan(keep_n) && ~isinf(keep_n)
                [~, ii] = sort(Fr.Frequency, 'descend');
                Fr = Fr(ii(1:keep_n),:);
            end
            
            ids = cellfun(@(x) find(strcmp(x, obj.V)), Fr.Term);
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
        
        function ED = exclude_word_ids(obj, ids)
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
        
        function N = newFrom(obj, T, Y)
            if nargin < 3
                Y = obj.Y;
            end
            
            N = io.DocumentSet(T, Y);
        end
        
        function c = compact(obj)
            c = io.DocumentSet(obj.T, obj.Y);
            c.V = obj.V;
            c.I = obj.I;
            c.T = [];
            c.Y = [];
        end
        
        function sD = applySubstitution(obj, substitutionMap)
            
            sV = cell(size(obj.V));
            for i=1:numel(obj.V)
                if substitutionMap.isKey(obj.V{i})
                    sV{i} = substitutionMap(obj.V{i});
                else 
                    sV{i} = obj.V{i};
                end
                
                %fprintf('%s -> %s \n', obj.V{i}, sV{i});
            end            
            
            sT = cellfun(@(x) sV(x)', obj.I, 'UniformOutput', false);
            sD = obj.newFrom(sT);
        end
        
        function Dnew = merge(obj, D2)
            Tnew = [obj.T; D2.T];
            Ynew = [obj.Y; D2.Y];
            
            Dnew = obj.newFrom(Tnew, Ynew);
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