classdef GACLexicalSubstitution < LexicalSubstitutionPreprocessor
    %GACLEXSUBSTITUTION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        K
        StructuralDescriptor
        GroupNumber
        p
        a
        z
    end
    
    methods
        function obj = GACLexicalSubstitution(varargin)
            obj = obj@LexicalSubstitutionPreprocessor(varargin{:});
        end
        
        function r = doExecute(obj, ~, args)
            W = args.Word2VecDocumentSet;
            A = double(squareform(pdist( W.m.X(W.Vi,:),'cosine')));
            
            clusteredLabels  = gacCluster(A, obj.GroupNumber, obj.StructuralDescriptor, obj.K, obj.a, obj.z);
            
            F = W.termFrequencies().Frequency;
            clusters = unique(clusteredLabels);
            substitutes = zeros(numel(clusters),1);
            for i=1:numel(clusters)           
                samples = find(clusteredLabels == clusters(i));
                substitute = samples(maxi(F(samples)));
                substitutes(i) = substitute;                
            end
            
            LI = cellfun(@(x) substitutes(clusteredLabels(x)), W.I, 'UniformOutput', false);
            LT = cellfun(@(x) W.V(x)', LI, 'UniformOutput', false);
            
            LW = io.Word2VecDocumentSet(W.m, LT, W.Y);
            
            r = struct('Out', LW);
        end
    end
    
    methods(Access = protected)
        function p = createPipelineInputParser(obj)
            p = createPipelineInputParser@pipeline.AtomicPipelineStep(obj);
            
            % Pipeline Input (=Dataset)
            addRequired(p, 'Word2VecDocumentSet', @(x) isa(x, 'io.Word2VecDocumentSet'));
        end
        
        function p = createConfigurationInputParser(obj)
            p = createConfigurationInputParser@pipeline.AtomicPipelineStep(obj);
            
            % Algorithm Parameters
            addParameter(p, 'K', 10, @is_pos_integer);
            addParameter(p, 'GroupNumber', 100, @is_pos_integer);
            addParameter(p, 'StructuralDescriptor', 'path', @(x) ischar(x) && (strcmp(x, 'zeta') || strcmp(x, 'path')) );
            addParameter(p, 'p', 1, @is_pos_integer);
            addParameter(p, 'a', true, @islogical);
            addParameter(p, 'z', 0.01, @isscalar);
            
            
            function b = is_pos_integer(x)
                b = isscalar(x) && x >= 1 && floor(x) == x;
            end
        end
        
        function config(obj, args)
            config@pipeline.AtomicPipelineStep(obj, args);
            
            obj.K = args.K;
            obj.StructuralDescriptor = args.StructuralDescriptor;
            obj.GroupNumber = args.GroupNumber;
            obj.p = args.p;
            obj.a = args.a;
            obj.z = args.z;
        end
    end
    
end

