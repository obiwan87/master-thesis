classdef AtomicPipelineStep < pipeline.PipelineStep
    %ATOMICPIPELINESTEP Summary of this class goes here
    %   Detailed explanation goes here    
    properties
        Args
        LastOutput
        SaveOutput = false
    end
    
    methods
        function obj = AtomicPipelineStep(varargin)
            obj.Args = varargin;
            results = obj.parseConfigurationInput(varargin);
            obj.config(results);            
        end
        
        function r = execute(obj, context, varargin)
            args = obj.parsePipelineInput(varargin);
            r = obj.doExecute(context, args);
            obj.LastOutput = r;
        end
    end
    
    methods(Abstract)
        r = doExecute(context, args);        
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
        
        function cleanup(obj)
            obj.LastOutput = [];
        end
    end
    
end

