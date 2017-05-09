function clusters = pairwise_clustering( dist_u, pL_, varargin )
%PAIRWISE_CLUSTERING Summary of this function goes here
%   Detailed explanation goes here

p = create_parser();
parse(p, varargin{:});

params = p.Results;

cutoff = params.Cutoff;
linkage_param = params.Linkage;
mergeCriterion = params.MergeCriterion;
scoreFunction = params.ScoreFunction;
a = params.ScoreFunctionParam1;
b = params.ScoreFunctionParam2;

dist_p = scoreFunction(pL_,dist_u,a,b);

Z = linkage(dist_p, linkage_param);
clusters = cluster(Z, 'cutoff', cutoff, 'criterion', mergeCriterion );

end

function p = create_parser()
p = inputParser;
p.KeepUnmatched = true;

% Algorithm Parameters
addParameter(p, 'MaxDistance', 0.8, @(x) x > 0);
addParameter(p, 'ScoreFunction', @(pL_,dists,a,b) pL_*a + dists/2*b, @(x) isa(x, 'function_handle'));
addParameter(p, 'ScoreFunctionParam1', 0.5, @(x) true);
addParameter(p, 'ScoreFunctionParam2', 0.5, @(x) true);
addParameter(p, 'Cutoff', 0.2, @(x) isscalar(x));
addParameter(p, 'Linkage', 'weighted', @(x) true);
addParameter(p, 'MergeCriterion', 'distance', @(x) true);

end
