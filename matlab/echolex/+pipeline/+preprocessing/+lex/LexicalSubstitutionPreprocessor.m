classdef LexicalSubstitutionPreprocessor < pipeline.preprocessing.Preprocessor
    %LexicalSubstitutionAlgorithm Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj = LexicalSubstitutionPreprocessor(varargin)
            obj = obj@pipeline.preprocessing.Preprocessor(varargin{:});
        end
    end
end

