function [ g ] = pgrid( step, varargin )
%GRID Syntactic sugar for grid creations

g = pipeline.GridFactory.createGrid(step, varargin{:});

end


