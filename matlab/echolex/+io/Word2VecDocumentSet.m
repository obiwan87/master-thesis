classdef Word2VecDocumentSet < io.DocumentSet
    %WORD2VECDOCUMENTSET Combines a DocumentSet with a Word2VecModel
    %   Detailed explanation goes here
    
    properties
        Vi
        m
    end
    
    methods
        function obj = Word2VecDocumentSet(m, s, labels)            
            obj@io.DocumentSet(s, labels);

            obj.m = m;
            obj.calculateTermsMapping();
        end
        
        function N = newFrom(obj, T)
            N = io.Word2VecDocumentSet(obj.m, T, obj.Y);
        end
    end
    
    methods(Access=protected)
        function calculateTermsMapping(obj)
            obj.extractVocabulary();
            [~, obj.Vi, ~] = intersect(obj.m.Terms, obj.V);
        end
    end
end

