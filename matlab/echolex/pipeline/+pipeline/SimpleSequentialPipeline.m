classdef SimpleSequentialPipeline
    %PIPELINE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Input
        Preprocessors
        FeatureExtractors
        Classifiers
        Labels
    end
    
    methods
        function obj = SimpleSequentialPipeline(input, labels, preprocessors, featureextractors, classifiers)
            obj.Input = input;
            obj.Labels = labels;
            obj.Preprocessors = preprocessors;
            obj.FeatureExtractors = featureextractors;
            obj.Classifiers = classifiers;
        end
        
        function execute(obj)
            
            function pname = simple_class(objekt)
                pname = strsplit(class(objekt), '.');
                pname = pname{end};
            end
            
            for i=1:numel(obj.Preprocessors)
                p = obj.Preprocessors{i};                   
                [preprocessed, labels] = p.execute(obj.Input, 'Labels', obj.Labels);
                for j=1:numel(obj.FeatureExtractors)
                    f = obj.FeatureExtractors{j};
                    features = f.execute(preprocessed);
                    for k=1:numel(obj.Classifiers)
                        c = obj.Classifiers{k};
                        result = c.execute(features, labels);
                        
                        fprintf('%s -> %s => %s',simple_class(p) , simple_class(f), simple_class(c));
                        result 
                    end
                end
            end
        end
    end
    
end

