classdef Sequence < pipeline.PipelineStep
    %SEQUENCE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Steps
    end
    
    methods
        function obj = Sequence(varargin)
            obj.Steps = varargin;
        end
        
        function r = execute(obj, varargin)
            in = varargin{:}; % Assumes only one input
            for i=1:numel(obj.Steps)
                step = obj.Steps{i};
                out = step.execute(in);
                in = out;
            end
            
            r = out;
        end
    end
    
end

