classdef Fork < pipeline.CompositePipelineStep
    %BRANCH Summary of this class goes here
    %   Detailed explanation goes her
    
    methods
        function obj = Fork(varargin)
            obj = obj@pipeline.CompositePipelineStep(varargin{:});
        end
    end
    
end

