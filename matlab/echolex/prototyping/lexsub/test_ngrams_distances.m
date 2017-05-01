W = Ws{7};
ngramsW = BigramFinder.generateAllNGrams(W, 2, true);
ngramsW.findBigrams();

rng default
%bigrams_ref = { 'Test', 'hallo', 'CEO', 'Chef', 'Geschaeftsfuehrer', 'COO', '\/_\''', '#_Yolo', '#_Bims', '***_Test', '***_Probe', 'neuer_Chef', 'neuer_CEO', 'neues_Haus', 'gute_Zeit', 'schlechtes_Wetter', 'kleiner_Mann', 'grosses_Kind', 'gute_Schuhe', 'bessere_Schule' };
%bigrams_ref = bigrams_ref';
ngramsW.w2vCount();
bigrams_ref = ngramsW.V(ngramsW.B==2 & ngramsW.ViCount >= 1);
 
bigram_dists = words_pdist2(W.m, bigrams_ref, bigrams_ref);
bigram_dists_agg = max(bigram_dists,[],3);
% ii = sorti(bigram_dists_agg,2);

bigram_dists_agg(isinf(bigram_dists_agg)) = 2;
ii = sub2ind(size(bigram_dists_agg), 1:size(bigram_dists_agg,1),1:size(bigram_dists_agg,1));
bigram_dists_agg(ii) = 0;

Z = linkage(squareform(bigram_dists_agg),'complete');
clusters = cluster(Z, 'cutoff', 0.7);