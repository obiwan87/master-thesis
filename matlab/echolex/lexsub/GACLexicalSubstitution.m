classdef GACLexicalSubstitution < LexicalSubstitutionPreprocessor
    %GACLEXSUBSTITUTION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
    end
    
    methods
        function obj = GACLexicalSubstitution()
            obj = obj@LexicalSubstitutionPreprocessor();
        end
        
        function r = doExecute(obj, context, args)
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
            obj.DictDeltaThresh = args.DictDeltaThresh;
            obj.MaxIter = args.MaxIterations;
        end
    end
    
end

