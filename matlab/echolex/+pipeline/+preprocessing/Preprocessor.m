classdef (Abstract) Preprocessor  < pipeline.PipelineStep
    %PREPROCESSOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj = Preprocessor(varargin)
            obj = obj@pipeline.PipelineStep(varargin{:});
        end
    end
    
end

