import pipeline.*
import pipeline.preprocessing.*
import pipeline.preprocessing.lex.*

import pipeline.featextraction.*
import pipeline.classification.*

% Create Sequential Pipeline

preprocessors = { 
    %LocalLexicalKnnSubstitution('K', 10, 'DictDeltaThresh', 10, 'MaxIterations', 10), ...
    %GlobalLexicalKnnSubstitution('K', 30), ...
    %NoPreprocessing(), ...
    ExcludeWords('MinCount', 2, 'MaxCount', Inf, 'KeepN', Inf), ...
    ExcludeWords('MinCount', 3, 'MaxCount', Inf, 'KeepN', Inf)};

featextractors = { TfIdf(), WordCountMatrix(), TfIdfVectorizer() };
classifiers = {SVMClassifier('KFold', 10)};

pipeline = SimpleSequentialPipeline(W, W.Y,preprocessors, featextractors, classifiers);
pipeline.execute()
    

