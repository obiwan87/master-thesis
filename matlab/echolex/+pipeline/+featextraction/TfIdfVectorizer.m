classdef TfIdfVectorizer < pipeline.featextraction.FeatureExtractor
    %TFIDFVECTORIZER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        m % Word2VecModel
    end
    
    methods        
        function r = execute(obj, varargin)
            args = obj.parsePipelineInput(varargin);
            D = args.DocumentSet;
            
            r = features.tfidfvectorizer(D.m.X(D.Vi,:),D.tfidf());
        end
    end
    
    methods(Access=protected)
        function p = createPipelineInputParser(obj)
            p = createPipelineInputParser@pipeline.featextraction.FeatureExtractor(obj);
            addRequired(p, 'DocumentSet', @(x) isa(x, 'io.Word2VecDocumentSet'));
        end
    end
    
end

