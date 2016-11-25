classdef Word2VecModel < handle
    %WORD2VECMODEL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Terms
        X
        Terms_hash
    end
    
    methods
        function obj = Word2VecModel(terms, vectors, terms_hash)
            obj.Terms = terms;
            
            if nargin < 3
                obj.Terms_hash = cellfun(@(x) hex2dec(DataHash(x)), terms);
            else
                obj.Terms = terms_hash;
            end
            
            obj.X = vectors;
        end
        
        function [v] = vector(obj, word)
            p = strcmp(obj.Terms, word);
            v = obj.X(p,:);
        end
        
        function [idx, d, T] = similar(obj, w, K)
            if nargin < 3
                K = 10;
            end
            
            if ischar(w)
                v = obj.vector(w);
            elseif isvector(w)
                v = w;
            end
            [idx, d] = knnsearch(obj.X, v, 'K', K, 'distance', ...
                'cosine');
            
            T = table(obj.Terms(idx), d', 'VariableNames', {'word', 'distance'});
            if nargout <= 0
                T %#ok<NOPRT>
            end
        end
        
        
        function plotknn( obj, w, k, highlight)
            if nargin < 4
                hightlight = {};
            end
            if ischar(w)
                idx = knnsearch(obj.X, obj.vector(w), 'K', k+1, 'distance', 'cosine');
                D = obj.X(idx,:);
            elseif isvector(w)
                if numel(w) ~= size(obj.X, 2)
                    error('Dimension of reference vector doesn''t match current model');
                end
                idx = knnsearch(obj.X, w, 'K', k, 'distance', 'cosine');
                D = vertcat(w, obj.X(idx,:));
            else
                error('Unsupported data format for ''w'': vector or word expected');
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
                if sum(strcmp(term,highlight)) <= 0
                    text(d(i+1,1), d(i+1,2), term);
                else
                    text(d(i+1,1), d(i+1,2), term, 'Color', 'blue');
                end
            end
            hold off
        end
    end
    
end
