function [ substitutionMap, clusterAssignmentMap, unseenWords, nns, dist] = nearest_cluster_substitution_ngrams(m, query_V, ref_V, ref_F, clusters, clusterWordMap, varargin )

assert(size(clusters,1) == size(ref_V,1));
assert(size(clusters,1) == size(ref_F,1));

params = create_parser(varargin);

method = params.Method;
maxDistance = params.MaxDistance;

% Unseen words
unseenWords = setdiff(query_V, ref_V);

if strcmp(method, 'min')
    f = @(x) min(x,[],2);
elseif strcmp(method, 'max')
    f = @(x) max(x,[],2);
elseif strcmp(method, 'average')
    f = @(x) mean(x,2);
end

all_dists = words_pdist2(m, unseenWords, ref_V);
C = unique(clusters);
cluster_dists = zeros(numel(unseenWords), numel(C));

cluster_freqs = zeros(numel(C), 1);

for i=1:numel(C)
    b = clusters == C(i);
    cluster_freqs(i) = sum(ref_F.Frequency(b));
    %         if cluster_freqs(i) > 1
    cluster_dists(:,i) = f(all_dists(:,b));
    %         else
    %             cluster_dists(:,i) = Inf;
    %         end
end

[dist, nns] = sort(cluster_dists, 2, 'ascend');

substitutionMap = containers.Map();
clusterAssignmentMap = containers.Map();

for i=1:size(nns,1)
    if dist(i,1) <= maxDistance
        substitutionMap(unseenWords{i}) = clusterWordMap{nns(i,1)};
        clusterAssignmentMap(unseenWords{i}) = nns(i,1);
    end
end
end

function params = create_parser(args)
p = inputParser;
addParameter(p, 'MaxDistance', 0.4, @(x) isscalar(x) && x >= 0);
addParameter(p, 'Method', 'average');

parse(p, args{:});

validatestring(p.Results.Method, {'centroids', 'max', 'average', 'min'}, mfilename, 'Method');

params = p.Results;
end