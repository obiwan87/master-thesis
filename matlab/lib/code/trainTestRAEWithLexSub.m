%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Code for
% Semi-Supervised Recursive Autoencoders for Predicting Sentiment Distributions
% Richard Socher, Jeffrey Pennington, Eric Huang, Andrew Y. Ng, and Christopher D. Manning
% Conference on Empirical Methods in Natural Language Processing (EMNLP 2011)
% See http://www.socher.org for more information or to ask questions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% load minFunc
addpath(genpath('tools/'))

%%%%%%%%%%%%%%%%%%%%%%
% Hyperparameters
%%%%%%%%%%%%%%%%%%%%%%
% set this to 1 to train the model and to 0 for just testing the RAE features (and directly training the classifier)
params.trainModel = 1;

% node and word size
params.embedding_size = 50;

% Relative weighting of reconstruction error and categorization error
params.alpha_cat = 0.2;

% Regularization: lambda = [lambdaW, lambdaL, lambdaCat, lambdaLRAE];
params.lambda = [1e-05, 0.0001, 1e-07, 0.01];

% weight of classifier cost on nonterminals
params.beta=0.5;

func = @norm1tanh;
func_prime = @norm1tanh_prime;

% parameters for the optimizer
options.Method = 'lbfgs';
options.display = 'on';
options.maxIter = 70;

disp(params);
disp(options);

%%%%%%%%%%%%%%%%%%%%%%
% Pre-process dataset
%%%%%%%%%%%%%%%%%%%%%%
% set this to different folds (1-10) and average to reproduce the results in the paper
params.CVNUM = 1;
preProFile = ['../data/rt-polaritydata/RTData_CV' num2str(params.CVNUM) '.mat'];
documentSetfile = '../data/rt-polaritydata/polarity_document_set.mat';
paramsFile = '../data/rt-polaritydata/params_unigrams.mat';

load(documentSetfile);
load(paramsFile);
load(preProFile);

D = W;
clear W;

D.w2vCount();

% cv = cvpartition(D.Y, 'Holdout', 0.1);
% train_ind = cv.training;
% test_ind  = cv.test;
% cv_ind    = test_ind;

[training_set,  test_set] = D.split(test_ind, train_ind);

% init training set
training_set.termFrequencies();
training_set.w2vCount();

% init test set
test_set.termFrequencies();
test_set.w2vCount();

[~, training_set_vocabulary_ind] = intersect(D.V(D.ViCount >= 1), training_set.V(training_set.ViCount >= 1));
[~, test_set_vocabulary_ind] = intersect(D.V(D.ViCount >= 1), training_set.V(test_set.ViCount >= 1));

training_set_vocabulary = D.V(training_set_vocabulary_ind);
test_set_vocabulary = D.V(test_set_vocabulary_ind);

training_set_freq = training_set.F;
substitution_freq = training_set_freq(training_set.ViCount >= 1, :);

disp('Calcuating pairwise word-vector distances ...');
% word-vector pairwise distances on the whole document set
Di = squareform(ngrams_pdist(D.m, D.V(D.ViCount >= 1), 1));

disp('Calcuating pairwise distributional distances ...');
% distributional pairwise distances only on the training set
L = binomial_likelihood_ratio(substitution_freq);

%%%%%%%%%%%%%%%%%%%
% Results store
%%%%%%%%%%%%%%%%%%%

all_results = zeros(size(params_ngrams, 1),2);
N = size(params_ngrams,1);

for i=1:numel(params_ngrams)
    fprintf('%d / %d', i, N);
    %%%%%%%%%%%%%%%%%%%%%
    % Initialize Lex-Sub Parameters
    %%%%%%%%%%%%%%%%%%%%%
    scoreFunction = @bayes_hypothesis_probability;
    linkag = 'complete';
    a = params_ngrams(i, 2)
    b = params_ngrams(i, 3)
    c = params_ngrams(i, 1)
    d = params_ngrams(i, 4)
    methodNearestClusterAssignment = 'min';
    
    % Apply substitutions
    max_clust = round(c * size(substitution_freq,1));
    
    training_set_distances = squareform(Di(training_set_vocabulary_ind, training_set_vocabulary_ind));
    
    disp('Clustering...');
    clusters = pairwise_clustering(training_set_distances , L, 'Linkage', linkag, 'MaxClust', max_clust, ...
        'ScoreFunction', scoreFunction, 'ScoreFunctionParam1', a, 'ScoreFunctionParam2', b);
    
    disp('Applying substitutions...');
    [substitution_map_model, clusterWordMap] = apply_cluster_substitutions2(substitution_freq, clusters);
    substitution_map_oov = nearest_cluster_substitution_ngrams(training_set.m, 1, D, Di, ...
        test_set_vocabulary, training_set_vocabulary, substitution_freq, ...
        clusters, clusterWordMap, ...
        'Method', methodNearestClusterAssignment, 'MaxDistance', d);
    
    combined_substitution_map = [substitution_map_model; substitution_map_oov];
    substituted_training_set = training_set.applySubstitution(substitution_map_model);
    substituted_test_set = test_set.applySubstitution(combined_substitution_map);
    
    % Build document with substitutions
    sT = cell(size(D.T));
    sT(train_ind) = substituted_training_set.T;
    sT(test_ind) = substituted_test_set.T;
    sY = zeros(size(D.Y));
    sY(train_ind) = D.Y(train_ind);
    sY(test_ind) = D.Y(test_ind);
    sD = io.DocumentSet(sT, sY);
    sD.terms2Indexes();
    
    allSNum = sD.I;
    allSStr = sD.T;
    r = 0.05;
    We2 = rand(params.embedding_size, numel(sD.V))*2*r - r;
    labels = sD.Y';
    
    sent_freq = ones(length(allSNum),1);
    [~,dictionary_length] = size(We2);
    
    % split this current fold into train and test
    index_list_train = cell2mat(allSNum(train_ind)');
    index_list_test = cell2mat(allSNum(test_ind)');
    index_list_cv = cell2mat(allSNum(cv_ind)');
    unq_train = sort(index_list_train);
    unq_cv = sort(index_list_cv);
    unq_test = sort(index_list_test);
    freq_train = histc(index_list_train,1:size(We2,2));
    freq_cv = histc(index_list_cv,1:size(We2,2));
    freq_test = histc(index_list_test,1:size(We2,2));
    freq_train = freq_train/sum(freq_train);
    freq_cv = freq_cv/sum(freq_cv);
    freq_test = freq_test/sum(freq_test);
    
    cat_size=1;% for multinomial distributions this would be >1
    numExamples = length(allSNum(train_ind));
    
    
    %%%%%%%%%%%%%%%%%%%%%%
    % Initialize parameters
    %%%%%%%%%%%%%%%%%%%%%%
    theta = initializeParameters(params.embedding_size, params.embedding_size, cat_size, dictionary_length);
    
    %%%%%%%%%%%%%%%%%%%%%%
    % Parallelize if on cluster
    %%%%%%%%%%%%%%%%%%%%%%
    p = gcp('nocreate');
    if isunix &&  isempty(p)
        numCores = feature('numCores');
        if numCores==16
            numCores=8;
        end
        parpool('local', numCores);
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%
    % Train/Test Model
    %%%%%%%%%%%%%%%%%%%%%%
    if params.trainModel
        
        lbl = labels(:,train_ind);
        snum = allSNum(train_ind);
        sent_freq_here = sent_freq(1:numExamples);
        
        [opttheta, cost] = minFunc( @(p)RAECost(p, params.alpha_cat, cat_size,params.beta, dictionary_length, params.embedding_size, ...
            params.lambda, We2, snum, lbl, freq_train, sent_freq, func, func_prime), ...
            theta, options);
        theta = opttheta;
        
        [W1, W2, W3, W4, b1, b2, b3, Wcat,bcat, We] = getW(1, theta, params.embedding_size, cat_size, dictionary_length);
        
        save(['../output/savedParams_CV' num2str(params.CVNUM) '.mat'],'opttheta','params','options');
        classifyWithRAE
        all_results(i, :) = [acc_train, acc_test];
        
    else
        if params.CVNUM ~= 1
            error('This is the optimal file for CV-fold 1')
        end
        load('../output/optParams_RT_CV1.mat')
        params.embedding_size = params.wordSize;
        params.alpha_cat = 0.2;
        params.trainModel = 0;
        classifyWithRAE
    end
end
