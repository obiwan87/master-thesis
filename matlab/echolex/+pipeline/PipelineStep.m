classdef (Abstract) PipelineStep < handle
    %PIPELINESTEP Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        NextStep
    end
    
    methods
        function obj = PipelineStep(varargin)
            results = obj.parseConfigurationInput(varargin);
            obj.config(results);            
        end
    end
    
    methods(Abstract)
        r = execute(varargin);
    end
    
    methods(Access=protected)
        function p = createPipelineInputParser(obj)
            p = inputParser;      
            p.KeepUnmatched = true;
            p.FunctionName = strcat(class(obj),'.execute');
        end
                        
        function results = parsePipelineInput(obj, args)
            p = obj.createPipelineInputParser();
            parse(p, args{:});
            results = p.Results;
        end
        
        function results = parseConfigurationInput(obj, args)
            p = obj.createConfigurationInputParser();
            parse(p, args{:});
            results = p.Results;
        end
        
        function p = createConfigurationInputParser(obj)
            p = inputParser;      
            p.KeepUnmatched = true;
            p.FunctionName = strcat(class(obj), '.configuration');
        end
        
        function config(~,~)
        end       
    end
end

