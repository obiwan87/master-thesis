rng default
W = Ws{1}; % Erweiterung
% 
% bigramFinder = BigramFinder.fromDocumentSet(W);
% W = bigramFinder.generateNgramsDocumentSet('student_t', 100);
% W.tfidf();
% 
% W = W.filter_vocabulary(2, Inf, Inf);
% W.tfidf();

%lexsub = LocalLexicalKnnSubstitution('K', 5, 'MaxIter', 1);
lexsub = GraphLexicalSubstitution('K', 5, 'Iterations', 1);
LW = lexsub.doExecute([], struct('DocumentSet', W)).Out;

W = LW;
W.tfidf();
bigramFinder = BigramFinder.fromDocumentSet(W);
W = bigramFinder.generateNgramsDocumentSet('student_t', 40);
W.tfidf();
X = full(W.wordCountMatrix());
partition = cvpartition(W.Y, 'holdout', 0.8);

trainset = training(partition, 1);
testset = test(partition, 1);

model = fitcnb(X(trainset, :), W.Y(trainset), 'Distribution', 'mn', 'Prior', [0.5 0.5]);
%model = fitcsvm(X(trainset,:), W.Y(trainset));
predictions = predict(model, X(testset,:));

sum(predictions == W.Y(testset))./sum(testset)

incorrectPredictions = find(testset);
incorrectPredictions = incorrectPredictions(W.Y(testset) ~= predictions);

S = W.T(incorrectPredictions);
S = cellfun(@(x) strjoin(x, ' '), S, 'UniformOutput', false);
S = table(S,W.Y(incorrectPredictions), incorrectPredictions);

F = W.termFrequencies();



%% Most discriminating words

diffprob = abs(diff(log(cell2mat(model.DistributionParameters))));
diffii = sorti(diffprob, 'descend');
maxprob = maxi(log(cell2mat(model.DistributionParameters)));
BestWords = table(W.V(diffii), diffprob(diffii)', model.ClassNames(maxprob(diffii)), F.Frequency(diffii));
