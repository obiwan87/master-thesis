classdef Word2VecModel < handle
    %WORD2VECMODEL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Terms
        X
        Frequencies
        NumberOfWords
    end
    
    methods
        function obj = Word2VecModel(terms, vectors)
            obj.Terms = terms;
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
        
        function d = plot(obj, idx)
            D = obj.X(idx,:);
            [coeff, ~] = pca(D);
            
            d = double(D * coeff(:,1:2));
            figure; scatter(d(:,1), d(:,2), '.');
            hold on
            
            for i=1:numel(idx)
                term = obj.Terms(idx(i));
                
                text(d(i,1), d(i,2), term, 'Interpreter', 'none');
                
            end
            hold off
            
        end
        
        function d = project2D(obj, idx)
            d = obj.project(idx, 2);
        end
        
        function d = project(obj, idx, N)
            D = obj.X(idx,:);
            [coeff, ~] = pca(D);
            
            d = double(D * coeff(:,1:N));
        end
        
        function plotknn( obj, w, k, highlight)
            if nargin < 3
                k = 10;
            end
            if nargin < 4
                highlight = {};
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
            figure; 
            scatter(d(1:end,1), d(1:end,2), '.w');
            hold on
            
            % Plot reference vector
            if ischar(w)
                text(d(1,1), d(1,2), w, 'Color', 'red', 'interpreter', 'none');
                idx(1) = [];
            else
                text(d(1,1), d(1,2), '<REF>', 'Color', 'red','interpreter', 'none');
            end
            
            for i=1:k
                term = obj.Terms(idx(i));
                if sum(strcmp(term,highlight)) <= 0
                    text(d(i+1,1), d(i+1,2), term, 'interpreter', 'none');
                else
                    text(d(i+1,1), d(i+1,2), term, 'Color', 'blue', 'interpreter', 'none');
                end
            end
            hold off
            
        end
        
        function h = plotanalogies(obj, words)
            [~,idxA,idxB] = intersect(m.Terms, words);
            idxA(idxB) = idxA;
            idx = idxA;
            d = obj.project2D(idx);
            
            h = scatter(d(:,1), d(:,2), '.');
            hold on
            for i = 1:(numel(idx)/2)
                j = (i-1)*2 + 1;
                
                % Capital
                w1 = words{j};
                v1 = d(j, :);
                % Country
                w2 = words{j+1};
                v2 = d(j+1, :);
                
                text(v2(1), v2(2), w2)%, 'BackgroundColor', 'w');
                arrow(v1,v2, 'Length', 5);
                text(v1(1), v1(2), w1)%, 'BackgroundColor', 'w');
            end
            hold off
            
        end
    end
    
end
