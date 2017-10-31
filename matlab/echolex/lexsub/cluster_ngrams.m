function clusters = pairwise_clustering(Z, varargin )
%PAIRWISE_CLUSTERING Summary of this function goes here
%   Detailed explanation goes here

p = create_parser();
parse(p, varargin{:});

params = p.Results;

cutoff = params.Cutoff;
maxClust = params.MaxClust;
mergeCriterion = params.MergeCriterion;

if isnan(maxClust)
clusters = cluster(Z, 'cutoff', cutoff, 'criterion', mergeCriterion );
else
    clusters = cluster(Z, 'maxclust', maxClust);
end

end

function p = create_parser()
p = inputParser;
p.KeepUnmatched = true;

% Algorithm Parameters
addParameter(p, 'Cutoff', 0.2, @(x) isscalar(x));
addParameter(p, 'MaxClust', nan, @(x) isscalar(x));
addParameter(p, 'MergeCriterion', 'distance', @(x) true);

end
