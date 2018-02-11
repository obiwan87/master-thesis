classdef Word2VecDocumentSet < io.DocumentSet
    %WORD2VECDOCUMENTSET Combines a DocumentSet with a Word2VecModel
    %   Detailed explanation goes here
    
    properties
        Vi
        m
        ViCount
    end
    
    methods
        function obj = Word2VecDocumentSet(m, s, labels, empty)            
            if nargin < 4
                empty = false;
            end
            
            obj@io.DocumentSet(s, labels, empty);
            
            if ~empty
                obj.m = m;                
                obj.calculateTermsMapping();                
            end
        end
        
        function N = newFrom(obj, T, Y)
            if nargin < 3
                Y = obj.Y;
            end
            N = io.Word2VecDocumentSet(obj.m, T, Y);
        end        
        
        function [trD, teD] = split(obj, testIdx, trainingIdx)                        
            trD = obj.subset(trainingIdx);
            teD = obj.subset(testIdx);                       
        end
        
        function sD = subset(obj, subsetIdx)            
            uI = unique(func.foldl(obj.I(subsetIdx), [], @(x,y) horzcat(x,y)));
            
            function ii = sub_idx(x)
                [~,~,ii] = intersect(x,uI,'stable');
                ii = ii';
            end
            
            sV = obj.V(uI);
            sT = obj.T(subsetIdx);
            sVi = obj.Vi(uI);
            sI = cellfun(@sub_idx, obj.I(subsetIdx), 'UniformOutput', false);
            
            sD = io.Word2VecDocumentSet([],[],[],true);
            sD.V = sV;
            sD.T = sT;
            sD.I = sI;
            sD.Vi = sVi;
            sD.Y = obj.Y(subsetIdx);            
            sD.m = obj.m;            
            
            if ~isempty(obj.W)
                sD.W = obj.W(subsetIdx,uI);                
            end
            
            if ~isempty(obj.B)
                sD.B = obj.B(uI);
            end
        end
                
        function calculateTermsMapping(obj)
            obj.extractVocabulary();
            obj.Vi = zeros(numel(obj.V), 1);
            [~,a1,b1] = intersect(lower(string(obj.V)),lower(string(obj.m.Terms)));
            obj.Vi(a1) = b1;
            
            [~,a2,b2] = intersect(obj.V,obj.m.Terms);
            obj.Vi(a2) = b2;            
        end        
        
        function w2vCount(obj)
            if isempty(obj.B)
                obj.findBigrams();
            end
            
            obj.ViCount = zeros(numel(obj.V),1);
            unigrams = obj.V(obj.B==1);
            unigrams_vi = obj.Vi(obj.B==1);
            w2vMap = containers.Map();
            for i=1:numel(unigrams)
                w2vMap(unigrams{i}) = unigrams_vi(i);
            end
-2            
            N = unique(obj.B);
            for i=1:numel(N)
                n = N(i);
                if n == 1
                    obj.ViCount(obj.Vi ~= 0) = 1;
                else
                    v = obj.V(obj.B==n);
                    ngrams = cellstr(string(v).split('_'));
                    counts = zeros(size(ngrams));
                    for j=1:n
                        counts(:,j) = cellfun(@(x) logical(w2vMap.isKey(x) && w2vMap(x)), ngrams(:,j));
                    end
                    obj.ViCount(obj.B==n) = sum(counts,2);
                end
            end
        end
    end
end

