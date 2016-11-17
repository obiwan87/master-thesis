classdef NoPreprocessing < pipeline.preprocessing.Preprocessor
    %NOPREPROCESSING Dummy preprocessor. Doesn't preprocess anything.
    
    properties
    end
    
    methods
        function [data, labels] = execute(~, varargin)
            % Blip Blop
            data = varargin{1};
            labels = varargin{3};
        end
    end
    
end

