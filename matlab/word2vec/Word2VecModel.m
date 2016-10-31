classdef Word2VecModel < handle
    %WORD2VECMODEL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Terms
        Vectors
    end
    
    methods
        function obj = Word2VecModel(terms, vectors)
            obj.Terms = terms;
            obj.Vectors = vectors;
        end
        
        function [v] = vector(obj, word)
            p = strcmp(obj.Terms, word);
            v = obj.Vectors(p,:);
        end
        
        function similar(obj, w, K)
            if nargin < 3
                K = 10;
            end
            
            if ischar(w)
                v = obj.vector(w);
            elseif isvector(w)
                v = w;
                endVv 
            [idx, d] = knnsearch(obj.Vectors, v, 'K', K, 'distance', ...
                'cosine');
            
            T = table(obj.Terms(idx), d', 'VariableNames', {'word', 'distance'})
            
        end
            
        function plotknn( obj, w, k)
            
            if ischar(w)            
                idx = knnsearch(obj.Vectors, obj.vector(w), 'K', k+1, 'distance', 'cosine');
                D = obj.Vectors(idx,:);
            elseif isvector(w)                
                if numel(w) ~= size(obj.Vectors, 2)
                    error('Dimension of reference vector doesn''t match current model');
                end                
                idx = knnsearch(obj.Vectors, w, 'K', k, 'distance', 'cosine');
                D = vertcat(w, obj.Vectors(idx,:));
            else
                error('Unsupported data format for ''w'': vector or word expected');
                return
            end
            
            [coeff, ~] = pca(D);
            
            d = double(D * coeff(:,1:2));
            figure; scatter(d(:,1), d(:,2), '.');
            hold on
            
            % Plot reference vector
            if ischar(w)
                text(d(1,1), d(1,2), w, 'Color', 'red');
                idx(1) = [];
            else
                text(d(1,1), d(1,2), '<REF>', 'Color', 'red');
            end
            
            for i=1:k
                term = obj.Terms(idx(i));                
                text(d(i+1,1), d(i+1,2), term);                
            end
            hold off
        end
    end
    
end

