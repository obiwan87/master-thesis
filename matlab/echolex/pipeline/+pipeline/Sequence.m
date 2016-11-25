classdef Sequence < pipeline.CompositePipelineStep
    %SEQUENCE Summary of this class goes here
    %   Detailed explanation goes here    
    
    methods
        function obj = Sequence(varargin)
            obj = obj@pipeline.CompositePipelineStep(varargin{:});
            
            for i=1:numel(obj.Children)-1
               obj.Children{i}.NextStep = obj.Children{i+1}; 
            end
            
            obj.Children{end}.NextStep = pipeline.EOP.getInstance;

        end
    end
    
end

