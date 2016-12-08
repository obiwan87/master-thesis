classdef NoOperation < pipeline.AtomicPipelineStep
    %NOOPERATION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Name
        Output
    end
    
    methods
        function obj = NoOperation(name, output)
            if nargin < 2
                output = [];
            end
            obj = obj@pipeline.AtomicPipelineStep('Name', name);
            obj.Name = name;
            obj.Output = output;
        end
        
        function out = doExecute(obj, ~, args)
            if isempty(obj.Output)
                out = args.Input;
            else
                out = obj.Output;
            end
            out = struct('Out', out);
        end
    end
    
    methods(Access=protected)
        function p = createPipelineInputParser(obj)
            p = createPipelineInputParser@pipeline.AtomicPipelineStep(obj);
            addRequired(p, 'Input', @(x) true);
        end
    end
end

