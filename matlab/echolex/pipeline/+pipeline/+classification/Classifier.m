classdef Classifier < pipeline.AtomicPipelineStep
    %CLASSIFIER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        CrossvalParams
        Repeat
    end
    
    methods
        function obj = Classifier(varargin)
            obj = obj@pipeline.AtomicPipelineStep(varargin{:});
        end
    end
    
    methods(Access=protected)
        function p = createPipelineInputParser(obj)
            p = createPipelineInputParser@pipeline.AtomicPipelineStep(obj);
        end
        function p = createConfigurationInputParser(obj)
            p = createConfigurationInputParser@pipeline.AtomicPipelineStep(obj);
            
            % Algorithm Parameters
            addParameter(p, 'CrossvalParams', {'kfold', 10}, @iscell);
            addParameter(p, 'Repeat', 1, @is_pos_integer);
            
            function b = is_pos_integer(x)
                b = isscalar(x) && x >= 1 && floor(x) == x;
            end
        end
        
        function config(obj, args)
            config@pipeline.AtomicPipelineStep(obj, args);
            obj.CrossvalParams = args.CrossvalParams;
            obj.Repeat = args.Repeat;
        end
    end
    
end

