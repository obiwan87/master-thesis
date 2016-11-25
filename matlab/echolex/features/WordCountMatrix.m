classdef WordCountMatrix < pipeline.featextraction.FeatureExtractor
    %WORDCOUNTMATRIXEXTRACTOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function r = doExecute(~, args)
            D = args.DocumentSet;
            r = struct('Out', datalabelprovider(full(D.wordCountMatrix()), D.Y));
        end
    end
    
    methods(Access=protected)
        function p = createPipelineInputParser(obj)
            p = createPipelineInputParser@pipeline.featextraction.FeatureExtractor(obj);
            addRequired(p, 'DocumentSet', @pipeline.inputvalidation.isbagofwords);
        end
    end    
end

