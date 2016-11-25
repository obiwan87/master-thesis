classdef (Abstract) Preprocessor  < pipeline.AtomicPipelineStep
    %PREPROCESSOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj = Preprocessor(varargin)
            obj = obj@pipeline.AtomicPipelineStep(varargin{:});
        end
    end
    
end

