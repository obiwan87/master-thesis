classdef GridFactory < handle
    %GRID Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods(Static)
        function grid = createGrid(step, varargin)
            args = cell(numel(varargin)/2, 1);
            for i=1:numel(args)
                v = varargin{2*i};
                if isnumeric(v) && ~iscell(v)
                    args{i} = num2cell(varargin{2*i});
                else
                    args{i} = varargin{2*i};
                end
            end
            
            parameterGrid = allcomb(args{:});
            
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

