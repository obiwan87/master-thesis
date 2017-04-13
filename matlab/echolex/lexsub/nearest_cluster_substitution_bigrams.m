function [ substitutionMap ] = nearest_cluster_substitution_bigrams( teD, trD, clusters, clusterWordMap, varargin )


substitutionMap = containers.Map();
params = create_parser(varargin);

method = params.Method;
maxDistance = params.MaxDistance;

% Unseen words
trD_bigrams = trD.V(trD.B);
teD_bigrams = teD.V(teD.B);
[uV, ~] = setdiff(teD_bigrams, trD_bigrams);

if isempty(uV)
    return
end

if strcmp(method, 'min')
    f = @(x) min(x,[],2);
elseif strcmp(method, 'max')
    f = @(x) max(x,[],2);
elseif strcmp(method, 'average')
    f = @(x) mean(x,2);
end

[bnns, bdist] = bigrams_pdist2(teD.m, trD_bigrams, uV);

C = unique(clusters);

cluster_dists = zeros(numel(uV), numel(C));
cluster_freqs = zeros(numel(C), 1);
trF = trD.termFrequencies();
trF = trF(trD.B,:);

all_dists = Inf(size(uV,1), size(trD_bigrams,1));

for i=1:numel(uV)
     all_dists(i,bnns{i}) = bdist{i};
end

for i=1:numel(C)
    b = clusters == C(i);
    cluster_freqs(i) = sum(trF.Frequency(b));
    if cluster_freqs(i) > 1
        cluster_dists(:,i) = f(all_dists(:,b));
    else
        cluster_dists(:,i) = Inf;
    end
end

[dist, nns] = sort(cluster_dists, 2, 'ascend');

for i=1:size(nns,1)
    if dist(i,1) <= maxDistance
        substitutionMap(uV{i}) = clusterWordMap{nns(i,1)};
    end
end
end

function params = create_parser(args)
p = inputParser;
addParameter(p, 'MaxDistance', 0.4, @(x) isscalar(x) && x >= 0);
addParameter(p, 'Method', 'centroids');

parse(p, args{:});

validatestring(p.Results.Method, {'centroids', 'max', 'average', 'min'}, mfilename, 'Method');

params = p.Results;
end