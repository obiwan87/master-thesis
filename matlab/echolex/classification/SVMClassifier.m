classdef SVMClassifier < pipeline.classification.Classifier
    %SVMCLASSIFIER Evaluates an SVM-Model with the passed parameters
    %   Detailed explanation goes here
    
    properties
        SVMParams
    end
    
    methods
        function obj = SVMClassifier(varargin)
            obj = obj@pipeline.classification.Classifier(varargin{:});
            obj.SVMParams = varargin;
            obj.SaveOutput = true;
        end
        
        function r = doExecute(obj, ~, args)
            dlp = args.DataLabelProvider;
            % For reproducibility, set default seed
            rng default
            svmmodel = fitcsvm(dlp.Data, dlp.Labels, obj.SVMParams{:});
            loss = kfoldLoss(svmmodel);
            r = struct();
            r.Out = struct('loss', loss, 'meanAccuracy', 1-loss);
            
            
            %            trainedModels = svmmodel.Trained;            
            %             accuracies = zeros(numel(trainedModels), 1);
            %             for i=1:numel(trainedModels)
            %                 trainedModel = trainedModels{i};
            %                 tii = test(svmmodel.Partition, i);
            %                 predictions = predict(trainedModel, args.Data(tii,:));
            %
            %                 accuracies(i) = sum(predictions == args.Labels(tii))/sum(tii);
            %             end
            
            % Loss and Accuracy are equivalent (accuracy = 1 - loss)
            % in binary classification.
        end
    end
    
    methods(Access=protected)
        function config(~, ~)
            
        end
    end
    
end

