classdef (Abstract) PipelineStep < handle
    %PIPELINESTEP Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        NextStep
        Parent
    end
    
    methods
        function S = asSequence(obj)
            parent = obj.Parent;
            S = pipeline.Sequence(obj);
            S.NextStep = obj.NextStep;
            S.Parent = parent;
            obj.NextStep = pipeline.EOP.getInstance;
        end
    end
    
end

