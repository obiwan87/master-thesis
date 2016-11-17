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
        end
        
        function r = execute(obj, varargin)
            args = obj.parsePipelineInput(varargin);
            
            % For reproducibility, set default seed
            rng default
            svmmodel = fitcsvm(args.Data, args.Labels, obj.SVMParams{:});
            
            r = struct('loss', kfoldLoss(svmmodel), 'meanAccuracy', -1);
            
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
            r.meanAccuracy = 1-r.loss;
        end
    end
    
    methods(Access=protected)
        function config(~, ~)
            
        end
    end
    
end

