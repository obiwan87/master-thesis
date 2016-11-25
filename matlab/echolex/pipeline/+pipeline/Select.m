classdef Select < pipeline.CompositePipelineStep
    %SELECT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        ObjectiveFcn
        ObjectiveStep 
    end
    
    methods
        function obj = Select(objectiveFcn, varargin)
            obj.Children = varargin;
            obj.ObjectiveFcn = objectiveFcn;
        end
    end
    
end

