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
        
        function r = doExecute(obj, ~, args)            
            D = args.DocumentSet;
            
            ED = D.filter_vocabulary(obj.MinCount, obj.MaxCount, obj.KeepN);
            ED.tfidf();            
            r = struct('Out', ED);
            info.vocSizeBefore = numel(D.V);
            info.vocSizeAfter = numel(ED.V);
            r.info = info;
        end
    end
    
    methods(Access=protected)
        function p = createConfigurationInputParser(obj)
            p = createConfigurationInputParser@pipeline.AtomicPipelineStep(obj);
            
            addParameter(p, 'MinCount', 2, @isscalar);
            addParameter(p, 'MaxCount', Inf, @isscalar);
            addParameter(p, 'KeepN', Inf, @isscalar);
        end
        
        function p = createPipelineInputParser(obj)
            p = createPipelineInputParser@pipeline.AtomicPipelineStep(obj);
            
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

