classdef CompositePipelineStep < pipeline.PipelineStep
    %COMPOSITEPIPELINESTEP Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Children
    end
    
    methods
        function obj = CompositePipelineStep(varargin)
            obj.Children = varargin;
            for i=1:numel(obj.Children)
                obj.Children{i}.Parent = obj;
            end
        end
    end
    
end

