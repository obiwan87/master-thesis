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
            obj.Vi = zeros(numel(obj.V), 1);
            [~,a,b] = intersect(lower(string(obj.V)),lower(string(obj.m.Terms)));
            obj.Vi(a) = b;
            
            [~,a,b] = intersect(obj.V,obj.m.Terms);
            obj.Vi(a) = b;
        end
    end
end

