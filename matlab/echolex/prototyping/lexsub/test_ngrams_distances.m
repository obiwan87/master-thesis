W = Ws{1};
ngramsW = BigramFinder.generateAllNGrams(W, 2, true);
ngramsW.findBigrams();

rng default
%bigrams_ref = { 'Test', 'hallo', 'CEO', 'Chef', 'Geschaeftsfuehrer', 'COO', '\/_\''', '#_Yolo', '#_Bims', '***_Test', '***_Probe', 'neuer_Chef', 'neuer_CEO', 'neues_Haus', 'gute_Zeit', 'schlechtes_Wetter', 'kleiner_Mann', 'grosses_Kind', 'gute_Schuhe', 'bessere_Schule' };
%bigrams_ref = bigrams_ref';
ngramsW.w2vCount();
q = ngramsW.B==1 & ngramsW.ViCount >= 1;
bigrams_ref = ngramsW.V(q);
F = ngramsW.termFrequencies();
F = F(q,:);
 
bigram_dists = words_pdist2(W.m, bigrams_ref, bigrams_ref);
K = normalized_kld(F,ngramsW.Y);
B = bernoulli_divergence(F);

cutoff = 0.1;
a = 0.5;
linkag = 'complete';
scoreFunction = @(pL_,dists,a,b) pL_*a + dists/2*b;
clusters = pairwise_clustering(bigram_dists, B, 'Linkage', linkag, 'Cutoff', cutoff, 'ScoreFunction', scoreFunction, 'ScoreFunctionParam1', a, 'ScoreFunctionParam2', 1-a);
freqs = histc(clusters, unique(clusters));
ii = sorti(freqs, 'descend');