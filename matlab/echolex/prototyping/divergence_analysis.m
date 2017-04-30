EW = Ws{2};
K = normalized_kld(EW,true);

B = bernoulli_divergence(EW, true);
C = calculate_unigrams_distances(EW,false,false);
F = EW.termFrequencies();
F = F(EW.Vi~=0,:);

M1 = max(cat(3,K,C/2),[],3);

a = 0.5;
M2 = a*K + (1-a)*C/2;
M3 = a*B + (1-a)*C/2;

cutoff1 = 0.3;

Z1 = linkage(squareform(M1),'complete');
clusters1 = cluster(Z1, 'cutoff', cutoff1, 'criterion', 'distance' );

cutoff2 = 0.15;

Z2 = linkage(squareform(M2),'complete');
clusters2 = cluster(Z2, 'cutoff', cutoff2, 'criterion', 'distance' );

cutoff3 = 0.3;

Z3 = linkage(squareform(M3),'complete');
clusters3 = cluster(Z3, 'cutoff', cutoff3, 'criterion', 'distance' );
