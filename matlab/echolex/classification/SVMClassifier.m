classdef SVMClassifier < pipeline.classification.Classifier
    %SVMCLASSIFIER Evaluates an SVM-Model with the passed parameters
    %   Detailed explanation goes here
    
    properties
        CrossvalParams
        Repeat
    end
    
    properties(Hidden)
        predictions = {};
    end
    
    methods
        function obj = SVMClassifier(varargin)
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
                svmmodel = fitcsvm(dlp.Data, dlp.Labels, 'CVPartition', c);
                lfcn = @(Y, Yfit, W, cost) obj.lossfun(Y, Yfit, W, cost);
                
                loss = kfoldLoss(svmmodel, 'mode', 'average', 'lossfun', lfcn);
                %classes = unique(dlp.Labels);
                %obj.predictions(i,:) = classes(obj.predictions(obj.predictions > 0));
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
            r.ClassificationResults = obj.predictions;
            
            
            % Loss and Accuracy are equivalent (accuracy = 1 - loss)
            % in binary classification.
        end
    end
    
    methods(Access=protected)
        % TODO: Finish
        function e = lossfun(obj, C, Sfit, W, ~)
            
            if size(C,2)==1
                e = 0;
                return;
            end
            
            % Classification error is the fraction of incorrect predictions
            notNaN = ~all(isnan(Sfit),2);
            [~,y] = max(C(notNaN,:),[],2);
            [~,yfit] = max(Sfit(notNaN,:),[],2);
            W = W(notNaN,:);
            e = sum((y~=yfit).*W) / sum(W);
            
            %obj.predictions(notNaN) = yfit;
        end
        
        
    end
    
    methods(Access=protected)
        function p = createConfigurationInputParser(obj)
            p = createConfigurationInputParser@pipeline.AtomicPipelineStep(obj);
            
            % Algorithm Parameters
            addParameter(p, 'CrossvalParams', {'kfold', 10}, @iscell);
            addParameter(p, 'Repeat', 1, @is_pos_integer);
            
            function b = is_pos_integer(x)
                b = isscalar(x) && x >= 1 && floor(x) == x;
            end
        end
        
        function p = createPipelineInputParser(obj)
            p = createPipelineInputParser@pipeline.classification.Classifier(obj);
            addRequired(p, 'DataLabelProvider', @(x) isa(x, 'pipeline.io.DataProvider') && isa(x, 'pipeline.io.LabelProvider') );
        end
        
        function config(obj, args)
            config@pipeline.AtomicPipelineStep(obj, args)
            
            obj.CrossvalParams = args.CrossvalParams;
            obj.Repeat = args.Repeat;
        end
    end
    
end


