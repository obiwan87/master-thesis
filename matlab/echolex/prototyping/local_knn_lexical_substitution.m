% Replace all words with its most frequent of k NNs that is more frequent than
% then reference word itself.

K = 8;
if ~exist('Vi', 'var')
    Vi = cellfun(@(x) find(strcmp(x,terms)), D.V);
end

ref = X(Vi,:); % reference subset of model
query = X(Vi,:); % query subset of model


%if ~exist('nns', 'var')
    % [nns, dist] = knnsearch(ref, query, 'K', K, 'distance', 'cosine');
    [nns, dist] = gknnsearch(ref,query,K,true);
%end

% Lexically substituted corpus
L = D.I;

% Params
DictDeltaThresh = 10; % Stop criterium: dictionary size between two iterations
MaxIter = 10;
folds = 14; % Number of folds for evaluation

dictSize = numel(unique(func.foldr(L,[], @(x,y) [x y])));
d = Inf;

losses = []; % SVM losses
accuracies = [];
F = D.termFrequencies();
k = 1;

% keep track of best lexically substituted corpus
minloss = Inf;

while d > DictDeltaThresh && k <= MaxIter
    
    for i=1:numel(L)
        sentence = L{i};
        subsentence = zeros(size(sentence));
        for j=1:numel(sentence)
            w = sentence(j);
            f = F.Frequency(nns(w,:)); % Frequencies of NNs of word w
            c = find(f > f(1), 1, 'first');
            s = w; % substitute
            
            if ~isempty(c)
                s = nns(w,c);
            end
            
            subsentence(j) = s;
        end
        L{i} = subsentence;
    end
    dictSizeBefore = dictSize;
    dictSize = numel(unique(func.foldr(L,[], @(x,y) [x y])));
    d = dictSizeBefore - dictSize;
    
    LT = cellfun(@(x) arrayfun(@(y) D.V{y}, x, 'UniformOutput', false), L, 'UniformOutput', false);
    LD = io.DocumentSet(LT, D.Y);
    
    % Classify using SVM    
    rng default
    SVMModel = fitcsvm(full(LD.tfidf()), LD.Y, 'KFold', folds);
    loss = kfoldLoss(SVMModel);
    
    if loss < minloss
        bestLD = LD;
        bestSVMModel = SVMModel;
        minloss = loss;
    end
    losses = [losses; numel(LD.V) loss]; %#ok<AGROW>
   % accs = crossval(@crossval_callback, full(LD.TfIdf),LD.Y, 'kfold', folds);
   % accuracies = [accuracies; mean(accs)]; %#ok<AGROW>
    
    k = k + 1;
end


losses