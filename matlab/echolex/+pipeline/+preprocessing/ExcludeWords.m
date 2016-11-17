classdef ExcludeWords < pipeline.preprocessing.Preprocessor
    %FILTERWORDS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        MinCount
        MaxCount
        KeepN
    end
    
    methods
        function obj = ExcludeWords(varargin)
            obj = obj@pipeline.preprocessing.Preprocessor(varargin{:});
        end
        
        function [D, labels] = execute(obj, varargin)
            args = obj.parsePipelineInput(varargin);
            D = args.DocumentSet;
            
            D = D.filter_vocabulary(obj.MinCount, obj.MaxCount, obj.KeepN);
            D.tfidf();            
            labels = D.Y;            
        end
    end
    
    methods(Access=protected)
        function p = createConfigurationInputParser(obj)
            p = createConfigurationInputParser@pipeline.PipelineStep(obj);
            
            addParameter(p, 'MinCount', 2, @isscalar);
            addParameter(p, 'MaxCount', 100, @isscalar);
            addParameter(p, 'KeepN', Inf, @isscalar);
        end
        
        function p = createPipelineInputParser(obj)
            p = createPipelineInputParser@pipeline.PipelineStep(obj);
            
            % Pipeline Input (=Dataset)
            addRequired(p, 'DocumentSet', @(x) isa(x, 'io.DocumentSet'));
        end
        
        function config(obj, args)
            obj.MinCount = args.MinCount;
            obj.MaxCount = args.MaxCount;
            obj.KeepN = args.KeepN;
        end
    end
    
end

