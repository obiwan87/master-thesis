classdef BigramFinder < NGramFinder
    %BIGRAMFINDER Wrapper for nltk.colloection.BigramCollocationsFinder
    
    properties(Access = private)
        pyBigramFinder
    end
    
    properties(Access = public)
        D
    end
    
    methods(Access = private)
        function obj = BigramFinder()
        end
    end
    
    methods(Access = public)
        function [nbestBigrams, readableBigrams] = nbest(obj, scoreFcn, n)
            if ischar(scoreFcn)
                scoreFcn = BigramFinder.findAssocMeasureFcn(scoreFcn);
            end
            
            pyNbestBigrams = obj.pyBigramFinder.nbest(scoreFcn, int32(n));
            nbestBigrams = cellfun(@(x) cellfun(@(y) char(y), cell(x), 'UniformOutput', false), cell(pyNbestBigrams), 'UniformOutput', false)';
            
            readableBigrams = cellfun(@(x) strjoin(cellfun(@(y) char(y), cell(x), 'UniformOutput', false), ' '), cell(pyNbestBigrams), 'UniformOutput', false)';
        end
        
        function bigramScores = ngramsScores(obj, scoreFcn)
            if ischar(scoreFcn)
                scoreFcn = BigramFinder.findAssocMeasureFcn(scoreFcn);
            end
            
            bigramScores = obj.pyBigramFinder.score_ngrams(scoreFcn);
            bigrams = cellfun(@(x) strjoin(cellfun(@(y) char(y), cell(x.cell{1}), 'UniformOutput', false), ' '), cell(bigramScores), 'UniformOutput', false)';
            scores = cell2mat(cellfun(@(x) double(x.cell{2}), cell(bigramScores), 'UniformOutput', false))';
            
            bigramScores = table(bigrams, scores, 'VariableNames', {'Bigram', 'Score'});
        end
        
        function [ND, bigrams] = generateNgramsDocumentSet(obj, scoreFcn, n)
            
            if n <= 0
                ND = obj.D;
                return
            end
            
            bigrams = obj.nbest(scoreFcn, n);
            bV = cellfun(@(x) strjoin(x, '_'), bigrams, 'UniformOutput', false);
            bV = sortrows(bV);
            V = unique([obj.D.V; bV]);
            bigramsVIdx = find(sum(string(V) == bV',2));
            
            bigrams_ = cell(numel(bigrams), 2);
            for i=1:numel(bigrams)
                bigrams_{i,1} = bigrams{i}{1};
                bigrams_{i,2} = bigrams{i}{2};
            end
            bigrams = bigrams_;
            bigrams = sortrows(bigrams, [1 2]);
            clear bigrams_
            
            matches = string(bigrams(:)) == string(obj.D.V)';
            matches = arrayfun(@(x) find(matches(x,:)), 1:size(matches,1));
            bigramsIdx = reshape(matches, size(bigrams,1), 2);
            
            N = 2;
            
            % Replace all occurences of the unigrams with bigrams... also
            % note the positions
            I = obj.D.I;
            newT = cell(size(I));
            [~,termsMapping] = intersect(V, obj.D.V);
            warning('off', 'MATLAB:hankel:AntiDiagonalConflict');
            
            for i=1:numel(I)
                sentence = [0 I{i}];
                n = numel(sentence);
                
                % Generate bigram sequences
                h = hankel(1:n, 1:N);
                h = h(1:n-N+1,:);
                h = reshape(h, numel(h)/2, 2);
                h = sentence( h );
                
                % Check for each bigram if it was extracted
                new_sentence = zeros(size(sentence));
                
                bigramFoundBefore = false;
                for j=1:size(h,1)
                    
                    b = h(j,:);
                    matches = sum(b == bigramsIdx,2) >= N;
                    
                    if ~any(matches)
                        v = b(2);
                        new_sentence(j) = termsMapping(v);
                        
                        bigramFoundBefore = false;
                    else
                        if ~bigramFoundBefore
                            new_sentence(j-1) = 0;
                        end
                        new_sentence(j) = bigramsVIdx(matches);
                        bigramFoundBefore = true;
                    end
                end
                
                newT{i} = V(new_sentence(new_sentence~=0))';
            end
            
            ND = obj.D.newFrom(newT);
            %ND.tfidf();
        end
    end
    
    methods(Static)
        
        function ND = generateAllNGrams(D, n, keepUnigrams)
            if nargin < 2
                n = 2;
            end
            
            if nargin < 3
                keepUnigrams = false;
            end
            
            startTokenTemplate = '*start*%d';
            endTokenTemplate = '*end*%d';
            
            T = cell(size(D.T));
            for i = 1:numel(D.T)
                sentence = D.T{i};   
                 
                T{i} = D.T{i};
                for N=2:n
                    startToken = sprintf(startTokenTemplate, N);
                    endToken = sprintf(endTokenTemplate, N);
                    sentence = [startToken sentence endToken];%#ok<AGROW>
                    ngrams_sentence = BigramFinder.calculateNGrams(sentence, N);                    
                    if keepUnigrams
                        T{i} = [T{i} ngrams_sentence];
                    else
                        T{i} = ngrams_sentence;
                    end
                end
            end
            
            ND = D.newFrom(T);
        end
        
        function r = calculateNGrams(s, N)
            warning('off', 'MATLAB:hankel:AntiDiagonalConflict');
            n = numel(s);
            
            h = hankel(1:n, 1:N);
            h = h(1:n-N+1,:);
            h = reshape(h, numel(h)/N, N);
            
            r = s( h );
            r = arrayfun(@(x) strjoin(r(x,:),'_'), 1:size(r,1),'UniformOutput', false);
        end
        
        function r = calculateNGramsPy(sentence, n)
              bigrams = cell(py.list(py.nltk.ngrams(sentence, n)));
              bigrams = cellfun(@(x) join(strrep(string(cell(x)),'_','-'), '_'), bigrams, 'UniformOutput', false);               
              r = cellstr(string(bigrams));
        end
        
        function obj = fromDocumentSet(D)
            obj = BigramFinder();
            obj.D = D;
            obj.pyBigramFinder = py.nltk.collocations.BigramCollocationFinder.from_documents(D.T');
        end
        
        function obj = fromWords(W, windowSize)
            obj = BigramFinder();
            obj.pyBigramFinder = py.nltk.collocations.BigramCollocationFinder.from_words(W, int32(windowSize));
        end
    end
    
    methods(Static, Access = private)
        function scoreFcn = findAssocMeasureFcn(scoreFcn)
            members = py.inspect.getmembers(py.nltk.metrics.association.BigramAssocMeasures);
            members = cell(members);
            member_names = cellfun(@(x) char(x.cell{1}), members, 'UniformOutput', false);
            
            scoreFcn = members{strcmp(member_names, scoreFcn)}.cell{2};
        end
    end
    
    methods (Static)
        function a = listAssocMeasures()
            members = py.inspect.getmembers(py.nltk.metrics.association.BigramAssocMeasures);
            members = cell(members);
            member_names = cellfun(@(x) char(x.cell{1}), members, 'UniformOutput', false);
            
            a = cellfun(@(x) x(1) == '_', member_names, 'UniformOutput', true);
            a = member_names(~a)';
        end
    end
end

