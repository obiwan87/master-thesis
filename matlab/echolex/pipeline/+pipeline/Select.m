classdef Select < pipeline.CompositePipelineStep
    %SELECT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        ObjectiveFunction
    end
    
    methods
        function obj = Select(objectiveFcn, varargin)
            obj.Children = varargin;
            obj.ObjectiveFunction = objectiveFcn;
            
        end
        
        function selector = createSelector(obj)
            selector = pipeline.InputSelector(obj.Children, obj.ObjectiveFunction);
        end
    end
    
end

