classdef NaiveBayesClassifier < pipeline.classification.Classifier
    %NAIVEBAYESCLASSIFIER Naive Bayes classifier as Pipeline Step
    
    %% TODO: This code is almost identical to SVMClassifier 
    % Create template function for doExecute
    
    %% Code    
    methods        
        function obj = NaiveBayesClassifier(varargin)
            obj = obj@pipeline.classification.Classifier(varargin{:});
            obj.SaveOutput = true;
        end
        
        function r = doExecute(obj, ~, args)
            dlp = args.DataLabelProvider;
            
            repeat = obj.Repeat;
            
            % For reproducibility, set default seed
            rng default
            r = struct();
            losses = zeros(repeat,1);
            %obj.predictions = zeros(repeat, size(dlp.Data,1));
            for i = 1:repeat
                c = cvpartition(dlp.Labels, obj.CrossvalParams{:});
                nbmodel = fitcnb(dlp.Data, dlp.Labels, 'CVPartition', c, 'Distribution', 'mn');                
                loss = kfoldLoss(nbmodel, 'mode', 'average');               
                losses(i) = loss;
            end
            r.Out = struct();
            r.Out.loss = loss;
            if repeat > 1
                r.Out.losses = losses;
                r.Out.accuracies = 1-losses;
                
                r.Out.loss = mean(losses);
            end
            r.Out.accuracy = 1 - r.Out.loss;
        end
    end
    
    methods(Access=protected)
        function p = createPipelineInputParser(obj)
            p = createPipelineInputParser@pipeline.classification.Classifier(obj);
            addRequired(p, 'DataLabelProvider', @(x) isa(x, 'pipeline.io.DataProvider') && isa(x, 'pipeline.io.LabelProvider') );
        end
    end
    
end

