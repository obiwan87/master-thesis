classdef TfIdfVectorizer < pipeline.featextraction.FeatureExtractor
    %TFIDFVECTORIZER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        m % Word2VecModel
    end
    
    methods        
        function r = doExecute(~, args)            
            D = args.DocumentSet;
            
            r = struct('Out', datalabelprovider(features.tfidfvectorizer(D.m.X(D.Vi,:),D.tfidf()), D.Y));
        end
    end
    
    methods(Access=protected)
        function p = createPipelineInputParser(obj)
            p = createPipelineInputParser@pipeline.featextraction.FeatureExtractor(obj);
            addRequired(p, 'DocumentSet', @(x) isa(x, 'io.Word2VecDocumentSet'));
        end
    end
    
end

