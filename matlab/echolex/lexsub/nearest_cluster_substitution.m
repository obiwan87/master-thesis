function [ substitutionMap, clusterAssignmentMap, unseenWords, nns, dist] = nearest_cluster_substitution( teD, trD, clusters, clusterWordMapVi, varargin )

params = create_parser(varargin);

method = params.Method;
maxDistance = params.MaxDistance;

% Unseen words
[uV, i_uV] = setdiff(teD.Vi, trD.Vi);

C = unique(clusters);

m = teD.m;
unseenWords = m.Terms(uV);
centroids = zeros(size(C,1), size(m.X,2));
Vi = trD.Vi(trD.Vi ~= 0);

if strcmp(method, 'centroids')
    
    for i=1:numel(C)
        
        c = C(i);
        b = c == clusters;
        
        centroids(i,:) = mean(m.X(Vi(b),:),1);
    end    
    [nns, dist] = knnsearch(centroids, m.X(uV,:), 'k', 1, 'distance', 'cosine');
    
else
    
    if strcmp(method, 'min')
        f = @(x) min(x,[],2);
    elseif strcmp(method, 'max')
        f = @(x) max(x,[],2);
    elseif strcmp(method, 'average')        
        f = @(x) mean(x,2);
    end
    
    all_dists = pdist2(m.X(uV,:), m.X(Vi,:), 'cosine');
    C = unique(clusters);
    cluster_dists = zeros(numel(uV), numel(C));
    
    cluster_freqs = zeros(numel(C), 1);
    trF = trD.termFrequencies();
    trF = trF(trD.Vi ~= 0,:);
    for i=1:numel(C)
        b = clusters == C(i);
        cluster_freqs(i) = sum(trF.Frequency(b));
%         if cluster_freqs(i) > 1
        cluster_dists(:,i) = f(all_dists(:,b));
%         else
%             cluster_dists(:,i) = Inf;
%         end        
    end
    
    [dist, nns] = sort(cluster_dists, 2, 'ascend');
end

substitutionMap = containers.Map();
clusterAssignmentMap = containers.Map();

for i=1:size(nns,1)    
    if dist(i,1) <= maxDistance    
        substitutionMap(teD.V{i_uV(i)}) = m.Terms{clusterWordMapVi(nns(i,1))};
        clusterAssignmentMap(teD.V{i_uV(i)}) = nns(i,1);
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