% W = Ws{7};
% ngramsW = BigramFinder.generateAllNGrams(W, 2, false);
% ngramsW.findBigrams();

rng default
% bigrams_ref = { '\/_\''', '#_Yolo', '#_Bims', '***_Test', '***_Probe', 'neuer_Chef', 'neuer_CEO', 'neues_Haus', 'gute_Zeit', 'schlechtes_Wetter', 'kleiner_Mann', 'grosses_Kind', 'gute_Schuhe', 'bessere_Schule' };
% bigrams_ref = bigrams_ref';
% bigrams_ref = ngramsW.V;
% 
% bigram_dists = ngrams_pdist2(W.m,bigrams_ref, bigrams_ref, 2);
% bigram_dists_agg = max(bigram_dists,[],3);
% ii = sorti(bigram_dists_agg,2);

bigram_dists_agg(isinf(bigram_dists_agg)) = 2;