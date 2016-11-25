classdef GlobalLexicalKnnSubstitution < LexicalSubstitutionPreprocessor
    %GLOBALLEXICALKNNSUBSTITUTION Lexical Substitution with global terms
    %   Collect NNs of local vocabulary with reference to global vocabulary.
    %   Replace terms with most frequent NNs.
    
    properties
        K
        Sigma
    end
    
    methods
        function obj = GlobalLexicalKnnSubstitution(varargin)
            obj = obj@LexicalSubstitutionPreprocessor(varargin{:});
        end
        function r = doExecute(obj, args)
            persistent D_            
            
            %Algorithm parameters
            sigma = obj.Sigma;
           
            D = args.Word2VecDocumentSet;  
            %Use cache?
            reuseNNs = ~isempty(D_) && D_ == D;                        
          
            DF = D.termFrequencies().Frequency;
            [LT, LVi] = GlobalLexicalKnnSubstitution.do(obj.K, D.I, D.V, D.m.X, D.m.Terms, D.Vi, DF, sigma, reuseNNs);
            
            LD = io.Word2VecDocumentSet(D.m, LT, D.Y);
            r = struct('Out', LD);
            
            % Additional information             
            info = struct();
            info.vocSizeBefore = numel(D.V);
            info.vocSizeAfter = numel(LD.V);
            info.LVi = LVi;
            
            r.info = info;
            
            D_ = D;
        end
    end
    
    methods(Static)
        function [LT, LVi] = do(K, I, V, X, terms, Vi, DF, sigma, reuseNNs)
            persistent nns_ K_ dist_

            if nargin < 8
                sigma = @(gF, lF, d) (gF + lF) ./ exp(d);
            end
            
            if nargin < 9
                reuseNNs = false;
            end
            
            if ~reuseNNs || K_ < K
                %fprintf('Calculating NNs ...')
                [nns, dist] = gknnsearch(X, X(Vi,:),K,true);
                %fprintf('done. \n');
            else
                nns = nns_(:,1:K);
                dist = dist_(:,1:K);
            end
            
            %fprintf('Caculating term frequencies of NNs...')
            N = unique(nns(:));
            F = histc(nns(:), unique(N));
            %fprintf('done. \n');
            
            %fprintf('Substituting terms ...')
            LVi = zeros(size(Vi));
            
            % new vocabulary
            for i=1:numel(V)
                idx = nns(i,:);
                
                ii = arrayfun(@(x) find(x==N),idx,'UniformOutput', true);
                lF = arrayfun(@(x) emptyas(DF(x==Vi)), idx, 'UniformOutput', true);
                f = sigma(F(ii)', lF, dist(i,:));
                [~,j] = max(f);
                
                LVi(i) = nns(i,j);
            end
            %fprintf('done. \n');
            
            %fprintf('Vocabulary size shrank from %d to %d terms \n', ...
                %numel(Vi), numel(unique(LVi)));
            
            LI = cellfun(@(s) LVi(s), I, 'UniformOutput', false);
            LT = cellfun(@(s) terms(s)', LI, 'UniformOutput', false);
            
            K_ = K;
            nns_ = nns;
            dist_ = dist;
        end
    end
    
    methods(Access=protected)
        function p = createPipelineInputParser(obj)
            p = createPipelineInputParser@pipeline.AtomicPipelineStep(obj);
            p.FunctionName = 'GlobalLexicalKnnSubstitution.execute';
            
            % Pipeline Input (=Dataset)
            addRequired(p, 'Word2VecDocumentSet', @(x) isa(x, 'io.Word2VecDocumentSet'));
        end
        
        function p = createConfigurationInputParser(obj)
            p = createConfigurationInputParser@pipeline.AtomicPipelineStep(obj);
            
            function b = is_pos_integer(x)
                b = isscalar(x) && x >= 1 && floor(x) == x;
            end
            
            % Algorithm Parameter
            addParameter(p, 'K', 10, @is_pos_integer);
            addParameter(p, 'Sigma', @(gF, lF, d) (gF + lF) ./ exp(d) , @(x) isa(x, 'function_handle'));
        end
        
        function config(obj, args)
            config@pipeline.AtomicPipelineStep(obj, args)
            
            obj.K = args.K;
            obj.Sigma = args.Sigma;
        end
    end
    
end

