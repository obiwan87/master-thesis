classdef CommonClassWords < pipeline.preprocessing.Preprocessor
    %COMMONCLASSWORDS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function r = doExecute(~, ~, args)
            D = args.DocumentSet;
            L = D.termLabels();
            b = 2.^numel(unique(D.Y)) - 1;
            B = binvec2dec(L);
            
            excluded_words = find(B < b);
            ED = D.exclude_word_ids(excluded_words);
            
            
            r = struct('Out', ED);
            r.info = struct();
            r.info.vocSizeBefore = numel(D.V);
            r.info.vocSizeAfter  = numel(D.V) - sum(B < b);
            r.info.excludedWords = excluded_words;
            r.info.remainingWords = find(B >= b);
        end
        
    end
    
    methods(Access=protected)
        function p = createPipelineInputParser(obj)
            p = createPipelineInputParser@pipeline.AtomicPipelineStep(obj);
            
            % Pipeline Input (=Dataset)
            addRequired(p, 'DocumentSet', @(x) isa(x, 'io.DocumentSet'));
        end
    end
    
end

