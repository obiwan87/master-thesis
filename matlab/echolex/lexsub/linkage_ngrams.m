function Z = linkage_ngrams( dist_u, pL_, varargin )
%PAIRWISE_CLUSTERING Summary of this function goes here
%   Detailed explanation goes here

p = create_parser();
parse(p, varargin{:});

params = p.Results;

linkage_param = params.Linkage;
scoreFunction = params.ScoreFunction;
a = params.ScoreFunctionParam1;
b = params.ScoreFunctionParam2;

dist_p = scoreFunction(pL_,dist_u,a,b);

Z = linkage(dist_p, linkage_param);

end

function p = create_parser()
p = inputParser;
p.KeepUnmatched = true;

% Algorithm Parameters
addParameter(p, 'ScoreFunction', @(pL_,dists,a,b) pL_*a + dists/2*b, @(x) isa(x, 'function_handle'));
addParameter(p, 'ScoreFunctionParam1', 0.5, @(x) true);
addParameter(p, 'ScoreFunctionParam2', 0.5, @(x) true);
addParameter(p, 'Linkage', 'weighted', @(x) true);


end
