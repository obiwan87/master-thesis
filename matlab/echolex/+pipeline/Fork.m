classdef Fork < handle
    %BRANCH Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Branches
    end
    
    methods
        function obj = Fork(varargin)
            obj.Branches = varargin;
        end
    end
    
end

