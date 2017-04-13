function [ clusters, verboseClusters ] = pairwise_clustering_bigrams( D, varargin )
%PAIRWISE_CLUSTERING_BIGRAMS Summary of this function goes here
%   Detailed explanation goes here


p = create_parser();
parse(p, varargin{:});

params = p.Results;

cutoff = params.Cutoff;
linkage_param = params.Linkage;
mergeCriterion = params.MergeCriterion;
scoreFunction = params.ScoreFunction;
bigramPidstParams = params.BigramsPDistParams;

a = params.ScoreFunctionParam1;
b = params.ScoreFunctionParam2;

if isempty(D.B)
    D.findBigrams();
end

bigrams = D.V(D.B);

[nns, bdist] = bigrams_pdist2(D.m, bigrams, bigrams, bigramPidstParams{:});

dist_p = nan(size(bigrams,1));

F_b = D.termFrequencies();
F_b = F_b(D.B,:);

K = F_b.PDocs + 1;
N = K + F_b.NDocs + 1;
P = K ./ N;
L = P.^K.*(1-P).^(N-K);

for i=1:size(bigrams,1)
    if ~isempty(nns{i})
        k = K(i) + K(nns{i});
        n = N(i) + N(nns{i});
        P_ = k./n;
        L_ = P_.^k.*(1-P_).^(n-k);
        pL_ = L_ ./ (L(i).*L(nns{i}) + L_);
        
        dist_p(i,nns{i}) = scoreFunction(pL_', bdist{i}, a, b);
    end
    dist_p(i,i) = 0;
end
dist_p(isnan(dist_p)) = 1;

Z = linkage(squareform(dist_p), linkage_param);
clusters = cluster(Z, 'cutoff', cutoff, 'criterion', mergeCriterion );

C = unique(clusters);
for i=1:numel(C)
    b = clusters == C(i);
    if sum(b) > 1
        F_b(b,:)
    end
end

verboseClusters = [];
end


function p = create_parser()
p = inputParser;
p.KeepUnmatched = true;

% Algorithm Parameters
addParameter(p, 'MaxDistance', 0.8, @(x) x > 0);
addParameter(p, 'ScoreFunction', @(pL_,dists,a,b) (1-2*pL_)*a + dists*b, @(x) isa(x, 'function_handle'));
addParameter(p, 'ScoreFunctionParam1', 0.5, @(x) true);
addParameter(p, 'ScoreFunctionParam2', 0.5, @(x) true);
addParameter(p, 'Cutoff', 0.4, @(x) isscalar(x));
addParameter(p, 'Linkage', 'complete', @(x) true);
addParameter(p, 'MergeCriterion', 'distance', @(x) true);
addParameter(p, 'BigramsPDistParams', {});

end