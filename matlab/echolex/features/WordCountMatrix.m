classdef WordCountMatrix < pipeline.featextraction.FeatureExtractor
    %WORDCOUNTMATRIXEXTRACTOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        KeepUnigrams % If true, decomposes ngrams to its unigrams and adds an entry to the word count matrix for each unigram
        Binary
    end
    
    methods
        function obj = WordCountMatrix(varargin)
            obj = obj@pipeline.featextraction.FeatureExtractor(varargin{:});
        end
        function r = doExecute(obj, ~, args)
            D = args.DocumentSet;
            
            if obj.KeepUnigrams
                text = D.get_text();
                ngramsIdx = strfind(D.V, '_');                
                ngramsIdx = find(~cellfun(@isempty, ngramsIdx));
                
                for i=1:numel(ngramsIdx)
                    ngram = D.V{ngramsIdx(i)};
                    % w1_w2 => w1_w2 w1 w2
                    text = strrep(text, ngram, [ngram ' ' strrep(ngram, '_', ' ')]);
                end
                
                text = cellfun(@(x) strsplit(x, ' '), strsplit(text, '\n'), 'UniformOutput', false);
                D = D.newFrom(text);
                
            end
            data = full(D.wordCountMatrix());
            
            if obj.Binary 
                data(data>1) = 1;
            end
            r = struct('Out', datalabelprovider(data, D.Y));
        end
    end
    
    methods(Access=protected)
        function p = createPipelineInputParser(obj)
            p = createPipelineInputParser@pipeline.featextraction.FeatureExtractor(obj);
            addRequired(p, 'DocumentSet', @pipeline.inputvalidation.isbagofwords);
        end
        
        function p = createConfigurationInputParser(obj)
            p = createConfigurationInputParser@pipeline.AtomicPipelineStep(obj);
            
            addParameter(p, 'KeepUnigrams', false, @islogical);
            addParameter(p, 'Binary', false, @islogical);
        end
        
        function config(obj, args)
            obj.KeepUnigrams = args.KeepUnigrams;
            obj.Binary = args.Binary;
        end
    end
end

