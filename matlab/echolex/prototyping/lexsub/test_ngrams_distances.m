% % 
W = Ws{2};
ngramsW = BigramFinder.generateAllNGrams(W, 2, true);
ngramsW.findBigrams();
ngramsW.w2vCount();
% rng default
%bigrams_ref = { 'Test', 'hallo', 'CEO', 'Chef', 'Geschaeftsfuehrer', 'COO', '\/_\''', '#_Yolo', '#_Bims', '***_Test', '***_Probe', 'neuer_Chef', 'neuer_CEO', 'neues_Haus', 'gute_Zeit', 'schlechtes_Wetter', 'kleiner_Mann', 'grosses_Kind', 'gute_Schuhe', 'bessere_Schule' };
%bigrams_ref = bigrams_ref';

% 
N = 2;
q = ngramsW.B==N & ngramsW.ViCount >= 1;
V = ngramsW.V(q); 
F = ngramsW.termFrequencies();
F = F(q,:);
m = 100;
D = ngrams_pdist(W.m, V, N);
D(isinf(D)) = m;
B = bernoulli_divergence_weighted(F,D,0.8);

% bigram_dists_agg = max(bigram_dists,[],3);
% % ii = sorti(bigram_dists_agg,2);
% 
% bigram_dists_agg(isinf(bigram_dists_agg)) = 2;
% ii = sub2ind(size(bigram_dists_agg), 1:size(bigram_dists_agg,1),1:size(bigram_dists_agg,1));
% bigram_dists_agg(ii) = 0;
% 
Z = linkage(B,'complete');
clusters = cluster(Z, 'cutoff', 0.8);
freqs = histc(clusters, unique(clusters));
ii = sorti(freqs, 'descend');