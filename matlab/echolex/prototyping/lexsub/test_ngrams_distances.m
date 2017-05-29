% % 
N = 1;
W = Ws{2};
ngramsW = BigramFinder.generateAllNGrams(W, N, true);
ngramsW.findBigrams();
ngramsW.w2vCount();
% rng default
%bigrams_ref = { 'Test', 'hallo', 'CEO', 'Chef', 'Geschaeftsfuehrer', 'COO', '\/_\''', '#_Yolo', '#_Bims', '***_Test', '***_Probe', 'neuer_Chef', 'neuer_CEO', 'neues_Haus', 'gute_Zeit', 'schlechtes_Wetter', 'kleiner_Mann', 'grosses_Kind', 'gute_Schuhe', 'bessere_Schule' };
%bigrams_ref = bigrams_ref';

q = ngramsW.B==N & ngramsW.ViCount >= 1;
V = ngramsW.V(q); 
F = ngramsW.termFrequencies();
F = F(q,:);
m = 100;
D = ngrams_pdist(W.m, V, N);
D(isinf(D)) = m;

% Bernoulli Divergence
B0 = bernoulli_divergence(F);

% Binomial
LB = binomial_likelihood_ratio(F);

% Beta-Binomial
%LBB = bbinomial_likelihood_ratio(F);

P0 = bayes_hypothesis_probability(LB,D,0,0.5);
%P1 = bayes_hypothesis_probability(LBB,D,1,0);
P2 = 0.5*B0 + 0.25*D;

% bigram_dists_agg = max(bigram_dists,[],3);
% % ii = sorti(bigram_dists_agg,2);
% 
% bigram_dists_agg(isinf(bigram_dists_agg)) = 2;
% ii = sub2ind(size(bigram_dists_agg), 1:size(bigram_dists_agg,1),1:size(bigram_dists_agg,1));
% bigram_dists_agg(ii) = 0;
% 
% Z = linkage(P1,'complete');
% clusters = cluster(Z, 'cutoff', 0.7);
% freqs = histc(clusters, unique(clusters));
% ii = sorti(freqs, 'descend');

Z2 = linkage(P0,'complete');
clusters2 = cluster(Z2, 'cutoff', 0.7);
freqs2 = histc(clusters2, unique(clusters2));
ii2 = sorti(freqs2, 'descend');