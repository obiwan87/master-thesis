classdef Classifier < pipeline.PipelineStep
    %CLASSIFIER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj = Classifier(varargin)
            obj = obj@pipeline.PipelineStep(varargin{:});
        end
    end
    
    methods(Access=protected)
        function p = createPipelineInputParser(obj)
            p = createPipelineInputParser@pipeline.PipelineStep(obj);
            
            addRequired(p, 'Data', @(x) isnumeric(x));
            addRequired(p, 'Labels', @(x) true);
        end
        
    end
    
end

