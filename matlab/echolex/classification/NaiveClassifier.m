classdef NaiveClassifier < pipeline.classification.Classifier
    %NAIVECLASSIFIER Classifies text samples by just counting the
    %occurences of words for each class and assigning them to the most
    %frequent class.
    
    methods
        function obj = NaiveClassifier(varargin)
            obj = obj@pipeline.classification.Classifier(varargin{:});
        end
        
        function r = doExecute(obj, ~, args)
            D = args.DocumentSet;
            rng default
            accuracies = zeros(obj.Repeat, 1);
            for i = 1:obj.Repeat
                c = cvpartition(D.Y, obj.CrossvalParams{:});
                predictions = zeros(size(D.Y));
                wordCountMatrix = D.wordCountMatrix();
                classes = unique(D.Y);
                
                for k=1:c.NumTestSets
                    cL = zeros(numel(D.V), numel(classes));
                    % Indices for training set
                    trainingIdx = training(c, k);
                    testIdx = find(test(c, k));
                    
                    % Find words the training set doesn't have
                    wordCountMatrixTraining = wordCountMatrix(trainingIdx, :);
                    w = find(sum(wordCountMatrixTraining) > 0);
                    
                    % Adapt term labels to match the current training set
                    for m=1:numel(classes)
                        cl = classes(m);
                        samples = D.Y(trainingIdx) == cl;
                        cw = sum(wordCountMatrixTraining(samples,:)) > 0;
                        cL(cw,m) = 1;
                    end
                    
                    for m=1:numel(testIdx)
                        idx = testIdx(m);
                        ii = intersect(D.I{idx}, w);
                        prediction = maxi(sum(cL(ii,:)));
                        predictions(idx) = classes(prediction);
                    end
                    
                end
                accuracies(i) = sum(predictions == D.Y) / numel(D.Y);
            end
            accuracy = mean(accuracies);
            loss = 1 - accuracy;
            r = struct('Out', struct('accuracy', accuracy, 'loss', loss));
        end
    end
    
    methods(Access=protected)
        function p = createPipelineInputParser(obj)
            p = createPipelineInputParser@pipeline.classification.Classifier(obj);
            
            % Pipeline Input (=Dataset)
            addRequired(p, 'DocumentSet', @(x) isa(x, 'io.DocumentSet'));
        end
    end
end

