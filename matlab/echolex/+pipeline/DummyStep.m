classdef DummyStep < pipeline.PipelineStep
    %DUMMYSTEP Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Name
    end
    
    methods
        function obj = DummyStep(name)
            obj.Name = name;
        end
        
        function r = execute(obj, varargin)
             fprintf('-> %s', obj.Name);
             r = 0;
        end
    end
    
end

