classdef NoOperation < pipeline.AtomicPipelineStep
    %NOOPERATION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Name
    end
    
    methods
        function obj = NoOperation(name)
            obj = obj@pipeline.AtomicPipelineStep('Name', name);
            obj.Name = name;
        end
        
        function out = doExecute(~, args)
            in = args.Input;
            out = struct('Out', in);
        end
    end
    
    methods(Access=protected)
        function p = createPipelineInputParser(obj)
            p = createPipelineInputParser@pipeline.AtomicPipelineStep(obj);
            addRequired(p, 'Input', @(x) true);
        end
    end
end

