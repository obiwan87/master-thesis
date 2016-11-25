classdef DummyStep < pipeline.AtomicPipelineStep
    %DUMMYSTEP Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Name
    end
    
    methods
        function obj = DummyStep(name)
            obj = obj@pipeline.AtomicPipelineStep('Name', name);
            obj.Name = name;
        end
        
        function r = doExecute(obj, ~)
            fprintf('-> %s', obj.Name);
            r = struct('Out', 0);
        end
        
        function createPipelineInputParser(obj)
            p = createPipelineInputParser@pipeline.AtomicPipelineStep(obj);
            addRequired(p, 'Input', @(x) true);
        end
    end
    
end

