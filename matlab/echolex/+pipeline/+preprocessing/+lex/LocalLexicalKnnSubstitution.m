classdef LocalLexicalKnnSubstitution < pipeline.preprocessing.lex.LexicalSubstitutionPreprocessor
    %LOCALLEXICALSUBSTITUTION Lexical substitution with local vocabulary
    % Replace all words with its most frequent of k NNs that is more frequent than
    % then reference word itself. The substitute is chosen from the
    % Dictionary of the reference document set.    
    
    properties
        K 
        DictDeltaThresh 
        
        MaxIter
    end
    
    methods               
        function obj = LocalLexicalKnnSubstitution(varargin)
            obj = obj@pipeline.preprocessing.lex.LexicalSubstitutionPreprocessor(varargin{:});
        end
        
        function [r, labels] = execute(obj, varargin)
            % Algorithm parameters
            args = obj.parsePipelineInput(varargin);           
            
            D = args.Word2VecDocumentSet;
            F = D.termFrequencies();
            
            results = pipeline.preprocessing.lex.LocalLexicalKnnSubstitution.doExecute(D.V,F,D.I,D.m.X,D.Vi,...
                obj.K,obj.DictDeltaThresh,obj.MaxIter); 
            
            r = io.Word2VecDocumentSet(D.m, results(end).DocumentSet, D.Y);
            labels = r.Y;
        end
    end
    
    methods(Static)
        function results = doExecute(V, F, I, X, Vi, K, DictDeltaThresh, MaxIter, IterationCallback)           
            if nargin < 9
                IterationCallback = @NOP;
            end
            
            %if isempty(nns)
            ref = X(Vi,:); % reference subset of model
            query = X(Vi,:); % query subset of model
            nns = gknnsearch(ref,query,K,true);
            %end
            
            L = I; % Lexically substituted corpus
            
            dictSize = numel(unique(func.foldr(L,[], @(x,y) [x y]))); % Initial dictionary size
            d = Inf; % Change in dictionary size between iterations
            
            % Create results structure
            results = repmat(struct('DocumentSet', []), K, 1);
            
            k = 1;
            while d > DictDeltaThresh && k <= MaxIter
                if k > 1
                    for i=1:numel(L)
                        sentence = L{i};
                        subsentence = zeros(size(sentence));
                        for j=1:numel(sentence)
                            w = sentence(j);
                            f = F.Frequency(nns(w,:)); % Frequencies of NNs of word w
                            c = find(f > f(1), 1, 'first');
                            s = w; % substitute
                            
                            if ~isempty(c)
                                s = nns(w,c);
                            end
                            
                            subsentence(j) = s;
                        end
                        L{i} = subsentence;
                    end
                    dictSizeBefore = dictSize;
                    dictSize = numel(unique(func.foldr(L,[], @(x,y) [x y])));
                    d = abs(dictSizeBefore - dictSize);
                end
                LT = cellfun(@(x) arrayfun(@(y) V{y}, x, 'UniformOutput', false), L, 'UniformOutput', false);                
                
                % Callback at the end of iteration (handy if you want to
                % optimize number of iterations needed).
                IterationCallback(LT)
                
                % Log results
                results(k).DocumentSet = LT;
                
                k = k + 1;
            end
            
            results = results(1:k-1); % Trim results in case we stopped earlier than MaxIter iterations
        end
    end
    
    methods(Access=protected)
        function p = createPipelineInputParser(obj)            
            p = createPipelineInputParser@pipeline.PipelineStep(obj);            
            
            % Pipeline Input (=Dataset)
            addRequired(p, 'Word2VecDocumentSet', @(x) isa(x, 'io.Word2VecDocumentSet'));
        end
        
        function p = createConfigurationInputParser(obj)
            p = createConfigurationInputParser@pipeline.PipelineStep(obj);
            
            % Algorithm Parameters
            addParameter(p, 'K', 10, @is_pos_integer);
            addParameter(p, 'DictDeltaThresh', 10, @is_pos_integer);
            addParameter(p, 'MaxIterations', 5, @is_pos_integer);
            
            function b = is_pos_integer(x)
                b = isscalar(x) && x >= 1 && floor(x) == x;
            end
        end
        
        function config(obj, args)
            config@pipeline.PipelineStep(obj, args);
            
            obj.K = args.K;
            obj.DictDeltaThresh = args.DictDeltaThresh;
            obj.MaxIter = args.MaxIterations;
        end
    end
end

