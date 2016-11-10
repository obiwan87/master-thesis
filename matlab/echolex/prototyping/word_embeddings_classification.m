% Get subset of model
Xt = X(Vi,:);

% Average word embeddings such that one sentence is the weighted average
% according to the Tf-Idf of its words.

Y = features.tfidfvectorizer(Xt,D.tfidf());
T = table(Y, labels);

% Continue on Classification Learner App