classdef GraphLexicalSubstitution < LexicalSubstitutionPreprocessor
    %GRAPHLEXICALSUBSTITUTION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj = GraphLexicalSubstitution(varargin)
            obj = obj@LexicalSubstitutionPreprocessor(varargin{:});
        end
    end
    
end

