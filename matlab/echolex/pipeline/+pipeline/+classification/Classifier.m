classdef Classifier < pipeline.AtomicPipelineStep
    %CLASSIFIER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
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
        
    end
    
end

