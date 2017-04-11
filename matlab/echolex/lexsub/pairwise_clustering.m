function [ clusters, verboseClusters ] = pairwise_clustering( D, varargin )
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
% Word2Vec-Model
m = D.m;

% Unigrams
w2v_u_i = D.Vi(~D.B);
w2v_u_i = w2v_u_i(w2v_u_i~=0);

dist_u = double(squareform(pdist(m.X(w2v_u_i,:),'cosine')));
dist_u(dist_u > 1) = 1;

% Frequencies of unigrams
F = D.termFrequencies();
F_u = F(~D.B & D.Vi ~= 0,:);

K = F_u.PDocs + 1;
N = K + F_u.NDocs + 1;
P = K./N;

L = P.^K.*(1-P).^(N-K);
L = L .* L';

k = K + K';
n = N + N';
P_ = k./n;
L_ = P_.^k.*(1-P_).^(n-k);
pL_ = L_ ./ (L + L_);
dist_p = scoreFunction(pL_,dist_u,a,b);
dist_p = double(~logical(eye(size(dist_p)))) .* dist_p;

Z = linkage(squareform(dist_p), linkage_param);
clusters = cluster(Z, 'cutoff', cutoff, 'criterion', mergeCriterion );

C = unique(clusters);


if nargout > 1
    verboseClusters = cell(size(C,1),2);
    for i=1:numel(C)
        c = C(i);
        t = F_u(clusters == c,:);
        mi = maxi(t.Frequency);
        verboseClusters{i,1} = t.Term{mi};
        verboseClusters{i,2} = t;
    end
else
    verboseClusters = [];
end

end

function p = create_parser()
p = inputParser;
p.KeepUnmatched = true;

% Algorithm Parameters
addParameter(p, 'MaxDistance', 0.8, @(x) x > 0);
addParameter(p, 'ScoreFunction', @(pL_,dists,a,b) (1-2*pL_)*a + dists*b, @(x) isa(x, 'function_handle'));
addParameter(p, 'ScoreFunctionParam1', 1.3, @(x) true);
addParameter(p, 'ScoreFunctionParam2', 0.7, @(x) true);
addParameter(p, 'Cutoff', 0.4, @(x) isscalar(x));
addParameter(p, 'Linkage', 'weighted', @(x) true);
addParameter(p, 'MergeCriterion', 'distance', @(x) true);

end

% ubedges.Weight = (1-bedges(ia,3))*100;
%
% bd = digraph(ubedges);
% bm = wadjacency(bd);
% bg = graph(bm,bd.Nodes,'lower');
%
%
% figure; bp = plot(bg, 'NodeLabel', bigrams, 'Layout', 'force', 'Iterations', 100);
% [bcluster_matrix, ~] = mcl(wadjacency(bg), [], [], [],[], 200);
% [~, bcluster_table] = deduce_mcl_clusters(bcluster_matrix, bigrams);
% [~, b_ii] = intersect(bcluster_table.Var2, bigrams);
% bclusters = bcluster_table.Var3(b_ii);
% bclusters = str2double(bclusters);
%
% bp.NodeCData = bclusters / max(bclusters);
% bp.MarkerSize = 12;
% colormap('lines')
% model = S;



% % Similarity + factor
% edgesScore = (1-edges(:,3)).^1.2.*(2*edges(:,4)).^1.5;
%
% edgesTable1 = table(edges(:,1:2),'VariableNames', {'EndNodes'});
% edgesTable2 = table(edges(:,2:-1:1),'VariableNames', {'EndNodes'});
%
% edgesTable1.Weight = edgesScore;
%

% %Apply MCL clustering
% [cluster_matrix, ~] = mcl(wadjacency(g), [], [], [],[],20);
% [~, cluster_table] = deduce_mcl_clusters(cluster_matrix, V);
% [~, v_ii] = intersect(cluster_table.Var2, V);
% clusters = cluster_table.Var3(v_ii);
% clusters = str2double(clusters);
%
% figure; p1 = plot(g, 'NodeLabel', V, 'Layout', 'force', 'Iterations', 100);
%
%
% p1.NodeCData = clusters / max(clusters);
% p1.MarkerSize = 12;
% colormap('prism')


% tic
% for i=1:size(dist_u,1)
%     
%     % Frequencies of current word
%     k = K(i);
%     n = N(i);
%     
%     % Max. joint likelihood
%     L12 = L(i) * L;
%     
%     % Probability of new model (after substitution)
%     P_ = (k + K)./(n + N);
%     
%     % Likelihood of merged model
%     L_ = P_.^(k+K).*(1-P_).^(n-k+N-K);
%     
%     pL_ = L_ ./ (L12 + L_);
%     
%     dist_p(i,:) = scoreFunction(pL_', dist_u(i,:),a,b);
% end
% toc

