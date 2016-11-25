classdef GridFactory < handle
    %GRID Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods(Static)
        function grid = createGrid(step, varargin)
            parameterGrid = allcomb(varargin{2:2:end});
            
            if isnumeric(parameterGrid)
                parameterGrid = num2cell(parameterGrid);
            end
            
            C = meta.class.fromName(step);
            grid = cell(size(parameterGrid, 1), 1);
            for i=1:size(parameterGrid, 1)
                parameters = cell(size(varargin));
                parameters(1:2:end) = varargin(1:2:end);
                parameters(2:2:end) = parameterGrid(i, :); %#ok<NASGU>
                grid{i} = eval(sprintf('%s(parameters{:})', C.Name));
            end
        end        
    end
    
end

