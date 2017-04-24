classdef LocalLexicalKnnSubstitution < LexicalSubstitutionPreprocessor
    %LOCALLEXICALSUBSTITUTION Lexical substitution with local vocabulary
    % Replace all words with its most frequent of k NNs that is more frequent than
    % then reference word itself. The substitute is chosen from the
    % Dictionary of the reference document set.
    
    properties
        K
        DictDeltaThresh
        MaxIter
        SubstitutionThreshold
        UpdateFrequencyFcn
    end
    
    methods
        function obj = LocalLexicalKnnSubstitution(varargin)
            obj = obj@LexicalSubstitutionPreprocessor(varargin{:});
        end
        
        function r = doExecute(obj, ~, args)
            % Algorithm parameters
            D = args.DocumentSet;
            F = D.termFrequencies();
            
            LVi = LocalLexicalKnnSubstitution.do(D.V,F,D.I,D.m.X,D.Vi,...
                obj.K,obj.DictDeltaThresh,obj.MaxIter,obj.SubstitutionThreshold, obj.UpdateFrequencyFcn);
            
            nZ = find(D.Vi ~= 0);
            S = 1:numel(D.V);
            S(nZ) = nZ(LVi(:,end));
            
            LI = cellfun(@(x) S(x), D.I, 'UniformOutput', false);
            LT = cellfun(@(x) D.V(x)', LI, 'UniformOutput', false);
            LD = io.Word2VecDocumentSet(D.m, LT, D.Y);
            LD.tfidf();
            r = struct('Out', LD);
            info = struct();
            info.vocSizeBefore = numel(D.V);
            info.vocSizeAfter = numel(LD.V);
            info.LVi = S;
            
            r.info = info;
        end
    end
    
    methods(Static)
        function LVi = do(V, F, I, X, Vi, K, DictDeltaThresh, MaxIter, SubstThresh, UpdateFrequencyFcn)
            %if isempty(nns)
            
            % Only words that are contained in word2vec model
            Vi = Vi(Vi~=0);
            ref = X(Vi,:); % reference subset of model
            query = X(Vi,:); % query subset of model
            
            [nns, distances] = knnsearch(ref,query,'k', K,'distance', 'cosine');
            
            L = I; % Lexically substituted corpus
            
            dictSize = numel(unique(func.foldr(L,[], @(x,y) [x y]))); % Initial dictionary size
            d = Inf; % Change in dictionary size between iterations
            
            % For each of the words contained in word2vec model analyze
            % nearest neighbors and keep track of the substitutions in each
            % iteration
            LVi = zeros(numel(Vi),MaxIter+1);
            LVi(:,1) = 1:numel(Vi);
            k = 1;
            while d > DictDeltaThresh && k <= MaxIter
                for i=1:size(Vi,1)
                    j = LVi(i,k);
                    f = F.Frequency(nns(j,:)); % Frequencies of NNs of word w
                    
                    if f(1) <= SubstThresh
                        c = find(f > f(1), 1, 'first');
                        
                        if ~isempty(c)
                            s = nns(j,c);
                            LVi(i,k+1) = s;
                            
                            % Substitution of word j with work s
                            f1 = f(1);
                            f2 = f(c);
                            
                            % compute distance 
                            distance = distances(j,c);
                            
                            [f1, f2] = UpdateFrequencyFcn(f1,f2,distance);
                            F.Frequency(nns(j,1)) = f1;
                            F.Frequency(nns(j,c)) = f2;
                        else
                            LVi(i,k+1) = j;
                        end
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
        
        %% Word frequency update functions. 
        % f1: Frequency of original word (substituted)
        % f2: Frequency of target word (substitute)
        
        function [nf1, nf2] = updateFrequencyDefault(f1, f2, ~)
            nf1 = f1;
            nf2 = f2;
        end
        
        function [nf1, nf2] = probabilisticFrequencyUpdate(f1, f2, d)
            nf1 = 0;
            nf2 = f2 + f1*(1-d); % 1 - d = cosine similarity, here interpreted as the CDP p(w_1 | w_2) = p(w_2 | w_1)
        end
        
    end
    
    %% Pipeline 
    methods(Access=protected)

        function p = createPipelineInputParser(obj)
            p = createPipelineInputParser@pipeline.AtomicPipelineStep(obj);
            
            % Pipeline Input (=Dataset)
            addRequired(p, 'DocumentSet', @(x) isa(x, 'io.Word2VecDocumentSet'));
        end
        
        function p = createConfigurationInputParser(obj)
            p = createConfigurationInputParser@pipeline.AtomicPipelineStep(obj);
            
            % Algorithm Parameters
            addParameter(p, 'K', 10, @is_pos_integer);
            addParameter(p, 'DictDeltaThresh', 10, @is_pos_integer);
            addParameter(p, 'MaxIterations', 5, @is_pos_integer);
            addParameter(p, 'SubstitutionThreshold', Inf, @(x) x > 0);
            addParameter(p, 'UpdateFrequencyFcn', @(x,y,z) LocalLexicalKnnSubstitution.updateFrequencyDefault(x,y,z), @(x) isempty(x) || isa(x, 'function_handle'));
            
            function b = is_pos_integer(x)
                b = isscalar(x) && x >= 1 && floor(x) == x;
            end
        end
        
        function config(obj, args)
            config@pipeline.AtomicPipelineStep(obj, args);
            
            obj.K = args.K;
            obj.DictDeltaThresh = args.DictDeltaThresh;
            obj.MaxIter = args.MaxIterations;
            obj.SubstitutionThreshold = args.SubstitutionThreshold;
            obj.UpdateFrequencyFcn = args.UpdateFrequencyFcn;
        end
    end
end

