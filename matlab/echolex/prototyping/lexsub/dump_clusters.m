% 
% W = Ws{7};
% 
% ngramsW = BigramFinder.generateAllNGrams(W, 3, true);
% ngramsW.findBigrams();
% ngramsW.termFrequencies();
% ngramsW.w2vCount();

% N = 3;
% q = ngramsW.B == N & ngramsW.ViCount >= 1;
% d = ngrams_pdist(W.m, ngramsW.V(q), N); 
dump_folder = fullfile(echolex_dumps, 'clusters');
%pL_ = bernoulli_divergence(ngramsW.F(q,:));

as = [0 0.1 0.2 0.3 0.4 0.5];
cutoffs = [0.1 0.2 0.3 0.4 0.5];
params = allcomb(as, cutoffs);
linkag = 'complete';
scoreFunction = @(pL_,dists,a,b) pL_*a + dists/2*b;

for i=1:size(params,1)
    a = params(i,1);
    b = 1-a;
    cutoff = params(i,2);    
    clusters = pairwise_clustering(d, pL_, 'Linkage', linkag, 'Cutoff', cutoff, 'ScoreFunction', scoreFunction, 'ScoreFunctionParam1', a, 'ScoreFunctionParam2', b);
    Fd = ngramsW.F(q,:);
    Fd.cluster = clusters;
    freqs = histc(clusters, unique(clusters));
    Fd.cluster_freq = freqs(Fd.cluster);
    Fd = sortrows(Fd,{'cluster_freq','cluster'},'descend');
    writetable(Fd(:,[1 4 5 6 7]),fullfile(dump_folder, sprintf('a%.2f c%.2f.txt', a,cutoff)), 'Delimiter', '\t');
end