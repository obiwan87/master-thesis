classdef GlobalLexicalKnnSubstitution < pipeline.preprocessing.lex.LexicalSubstitutionPreprocessor
    %GLOBALLEXICALKNNSUBSTITUTION Lexical Substitution with global terms
    %   Collect NNs of local vocabulary with reference to global vocabulary.
    %   Replace terms with most frequent NNs.
    
    properties
        K
    end
    
    methods
        function obj = GlobalLexicalKnnSubstitution(varargin)
            obj = obj@pipeline.preprocessing.lex.LexicalSubstitutionPreprocessor(varargin{:});
        end
        function [r, labels] = execute(obj, varargin)
            % Algorithm parameters
            args = obj.parsePipelineInput(varargin);
            
            % Prepare input            
            D = args.Word2VecDocumentSet;
            
            LT = pipeline.preprocessing.lex.GlobalLexicalKnnSubstitution.doExecute(obj.K, D.I, D.V, D.m.X, D.m.Terms, D.Vi);
            
            LD = io.Word2VecDocumentSet(D.m, LT, D.Y);            
            r = LD;
            labels = LD.Y;
        end        
    end
    
    methods(Static)
         function LT = doExecute(K, I, V, X, terms, Vi)
                                         
            %if isempty(nns)
            fprintf('Calculating NNs ...')
            nns = gknnsearch(X, X(Vi,:),K,true);
            fprintf('done. \n');
            %end
            
            fprintf('Caculating term frequencies of NNs...')
            N = unique(nns(:));
            F = histc(nns(:), unique(N));
            fprintf('done. \n');
            
            fprintf('Substituting terms ...')
            LVi = zeros(size(Vi));
            % new vocabulary
            for i=1:numel(V)
                idx = nns(i,:);              
                
                ii = arrayfun(@(x) find(x==N),idx,'UniformOutput', true);
                [~,j] = max(F(ii));
                
                LVi(i) = nns(i,j);
            end
            fprintf('done. \n');
            
            fprintf('Vocabulary size shrinked from %d to %d terms \n', ...
                numel(Vi), numel(unique(LVi)));
            
            LI = cellfun(@(s) LVi(s), I, 'UniformOutput', false);
            LT = cellfun(@(s) terms(s)', LI, 'UniformOutput', false);
        end
    end

    methods(Access=protected)
        function p = createPipelineInputParser(obj)
            p = createPipelineInputParser@pipeline.PipelineStep(obj);            
            p.FunctionName = 'GlobalLexicalKnnSubstitution.execute';
            
            % Pipeline Input (=Dataset)
            addRequired(p, 'Word2VecDocumentSet', @(x) isa(x, 'io.Word2VecDocumentSet'));
        end
        
        function p = createConfigurationInputParser(obj)
            p = createConfigurationInputParser@pipeline.PipelineStep(obj);
            
            function b = is_pos_integer(x)
                b = isscalar(x) && x >= 1 && floor(x) == x;
            end
            
            % Algorithm Parameter
            addParameter(p, 'K', 10, @is_pos_integer);
        end
        
        function config(obj, args)
            config@pipeline.PipelineStep(obj, args)
            
            obj.K = args.K;
        end
    end
    
end

