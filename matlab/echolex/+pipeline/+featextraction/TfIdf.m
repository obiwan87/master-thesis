classdef TfIdf < pipeline.featextraction.FeatureExtractor
    %TFIDFEXTRACTOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods        
        function r = execute(obj, varargin)
            D = obj.parsePipelineInput(varargin).DocumentSet;            
            r = full(D.tfidf());
        end
    end
    
    methods(Access=protected)
        function p = createPipelineInputParser(obj)
            p = createPipelineInputParser@pipeline.featextraction.FeatureExtractor(obj);
            addRequired(p, 'DocumentSet', @pipeline.inputvalidation.isbagofwords);
        end
    end
end

