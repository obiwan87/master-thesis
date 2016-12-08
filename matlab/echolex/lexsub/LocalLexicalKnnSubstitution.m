classdef LocalLexicalKnnSubstitution < LexicalSubstitutionPreprocessor
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
            obj = obj@LexicalSubstitutionPreprocessor(varargin{:});
        end
        
        function r = doExecute(obj, ~, args)
            % Algorithm parameters
            D = args.Word2VecDocumentSet;
            F = D.termFrequencies();
            
            LVi = LocalLexicalKnnSubstitution.do(D.V,F,D.I,D.m.X,D.Vi,...
                obj.K,obj.DictDeltaThresh,obj.MaxIter);

            LI = cellfun(@(x) LVi(x,end), D.I, 'UniformOutput', false);
            LT = cellfun(@(x) D.V(x)', LI, 'UniformOutput', false);
            LD = io.Word2VecDocumentSet(D.m, LT, D.Y);
            r = struct('Out', LD);
            info = struct();
            info.vocSizeBefore = numel(D.V);
            info.vocSizeAfter = numel(LD.V);
            info.LVi = LVi;
            
            r.info = info;
        end
    end
    
    methods(Static)
        function LVi = do(V, F, I, X, Vi, K, DictDeltaThresh, MaxIter)            
            %if isempty(nns)
            ref = X(Vi,:); % reference subset of model
            query = X(Vi,:); % query subset of model
            nns = gknnsearch(ref,query,K,true);
            %end
            
            L = I; % Lexically substituted corpus
            
            dictSize = numel(unique(func.foldr(L,[], @(x,y) [x y]))); % Initial dictionary size
            d = Inf; % Change in dictionary size between iterations
            
            LVi = zeros(numel(V),MaxIter+1);
            LVi(:,1) = 1:numel(V);
            k = 1;
            while d > DictDeltaThresh && k <= MaxIter                
                for i=1:numel(V)
                    j = LVi(i,k);
                    f = F.Frequency(nns(j,:)); % Frequencies of NNs of word w
                    c = find(f > f(1), 1, 'first');
                    
                    if ~isempty(c)
                        s = nns(j,c);
                        LVi(i,k+1) = s;
                    else
                        LVi(i,k+1) = j;
                    end
                end                
                dictSizeBefore = dictSize;
                dictSize = numel(unique(LVi(:,k+1)));
                d = abs(dictSizeBefore - dictSize);
                
                k = k + 1;
            end
            
            LVi = LVi(:,2:k); % Trim results in case we stopped earlier than MaxIter iterations
        end
    end
    
    methods(Access=protected)
        function p = createPipelineInputParser(obj)
            p = createPipelineInputParser@pipeline.AtomicPipelineStep(obj);
            
            % Pipeline Input (=Dataset)
            addRequired(p, 'Word2VecDocumentSet', @(x) isa(x, 'io.Word2VecDocumentSet'));
        end
        
        function p = createConfigurationInputParser(obj)
            p = createConfigurationInputParser@pipeline.AtomicPipelineStep(obj);
            
            % Algorithm Parameters
            addParameter(p, 'K', 10, @is_pos_integer);
            addParameter(p, 'DictDeltaThresh', 10, @is_pos_integer);
            addParameter(p, 'MaxIterations', 5, @is_pos_integer);
            
            function b = is_pos_integer(x)
                b = isscalar(x) && x >= 1 && floor(x) == x;
            end
        end
        
        function config(obj, args)
            config@pipeline.AtomicPipelineStep(obj, args);
            
            obj.K = args.K;
            obj.DictDeltaThresh = args.DictDeltaThresh;
            obj.MaxIter = args.MaxIterations;
        end
    end
end

