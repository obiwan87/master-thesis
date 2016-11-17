% Collect NNs of local vocabulary with reference to global vocabulary.
% Replace terms with most frequent NNs.
K = 50;
if ~exist('Vi', 'var')
    Vi = cellfun(@(x) find(strcmp(x,terms)), D.V);
end
folds = 10;
ref = X; % reference subset of model
query = X(Vi,:); % query subset of model
%if ~exist('gnns', 'var')
    % [nns, dist] = knnsearch(ref, query, 'K', K, 'distance', 'cosine');
    disp('Calculating NNs ...')
    [gnns, dist] = gknnsearch(ref,query,K,true);
%end

N = unique(gnns(:));
F = histc(gnns(:), N);
numDocs = numel(D.T);
dims = 2; %PCA dims
disp('Substituting terms ...')
LVi = zeros(size(Vi));
epsilon = 0.5;
inF = D.termFrequencies();
% new vocabulary
for i=1:numel(D.V)    
    idx = gnns(i,:);
    if mod(i,100)==0
        fprintf('%d / %d \n', i, numel(D.V));
    end
    
    I = arrayfun(@(x) find(x==N),idx,'UniformOutput', true);
    realF = arrayfun(@(x) emptyas(inF.Frequency(strcmp(terms{x}, D.V))), idx, 'UniformOutput', true);
 %   realF = F(I) + realF';
    realF = (F(I) + realF')./(exp(1.3*dist(i,:)'));
    [~,j] = max(realF);

    LVi(i) = gnns(i,j);    
end


fprintf('Vocabulary size shrank from %d to %d words \n', numel(Vi), numel(unique(LVi)));

LI = cellfun(@(s) LVi(s), D.I, 'UniformOutput', false);
LT = cellfun(@(s) terms(s)', LI, 'UniformOutput', false);

% Find out which substitutions happened within the corpus
innerCorpusSubstitutions = arrayfun(@(x) emptyas(find(strcmp(terms{x}, D.V)), -1), LVi);

disp('Training SVM model with TF-IDF features...');
LD = io.DocumentSet(LT, D.Y);
gSVMModel = fitcsvm(full(LD.tfidf()), LD.Y, 'KFold', folds);
loss = kfoldLoss(gSVMModel)