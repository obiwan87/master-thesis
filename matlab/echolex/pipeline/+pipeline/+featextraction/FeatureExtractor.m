classdef (Abstract) FeatureExtractor < pipeline.AtomicPipelineStep
    %FEATUREEXTRACTOR Superclass of all feature extractors in pipeline
    
    methods
        function obj = FeatureExtractor(varargin)
            obj  = obj@pipeline.AtomicPipelineStep(varargin{:});
        end
    end    
end

