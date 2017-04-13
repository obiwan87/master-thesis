% W = Ws{1};
% % just for test purposes filter out words occuring less than 5 times
% EW = W.filter_vocabulary(5,Inf,Inf);
% EW.tfidf();
% bigramFinder = BigramFinder.fromDocumentSet(EW);
% scores = bigramFinder.ngramsScores('raw_freq');
% bEW = bigramFinder.generateNgramsDocumentSet('raw_freq', size(scores,1));
%     
% c = cvpartition(bEW.Y, 'holdout', 0.5);
% 
% trD = io.Word2VecDocumentSet(bEW.m, bEW.T(training(c)), bEW.Y(training(c)));
% trD.tfidf();
% teD = io.Word2VecDocumentSet(bEW.m, bEW.T(test(c)), bEW.Y(test(c)));
% teD.tfidf();

[bnns, bdist, B_ref, bigrams_ref, B_query, bigrams_query] = bigrams_nns(trD,trD);