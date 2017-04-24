classdef NGrams < pipeline.preprocessing.Preprocessor
    %NGrams Returns a document set in which the unigrams are replaced with
    %       bigrams
    %   Uses NLTK's (python) implementation 
    
    properties
        N
        NBest
        ScoreFcn
        WindowSize
    end
    
    methods
        function obj = NGrams(varargin)
            obj = obj@pipeline.preprocessing.Preprocessor(varargin{:});
        end
        
        %                      obj, context, input arguments
        function r = doExecute(obj, ~, args)                 
            D = args.DocumentSet;
            
            if obj.N == 2                
                ngramFinder = BigramFinder.fromDocumentSet(D);     
            elseif obj.N > 2
                error('N-Grams with N > 2 not yet supported');
            end
            
            ND = ngramFinder.generateNgramsDocumentSet(obj.ScoreFcn, obj.NBest);
            r = struct('Out', ND);
        end
    end
    
    methods(Access=protected)
        function p = createConfigurationInputParser(obj)
            p = createConfigurationInputParser@pipeline.AtomicPipelineStep(obj);
            
            addParameter(p, 'N', 2, @(x) x==2 || x==3);
            addParameter(p, 'NBest', 100, @(x) isscalar(x) && x >= 0);
            addParameter(p, 'WindowSize', 2, @(x) isscalar(x) && x > 1);
            addParameter(p, 'ScoreFcn', 'raw_freq');
        end
        
        function p = createPipelineInputParser(obj)
            p = createPipelineInputParser@pipeline.AtomicPipelineStep(obj);
            
            % Pipeline Input (=Dataset)
            addRequired(p, 'DocumentSet', @(x) isa(x, 'io.DocumentSet'));
        end
        
        function config(obj, args)
            obj.N = args.N;
            obj.NBest = args.NBest;
            obj.ScoreFcn = args.ScoreFcn;
            obj.WindowSize = args.WindowSize;
        end
    end
    
end

