function [ clusters, V] = create_substitution_model( D, varargin )
%CREATE_SUBSTITUTION_MODEL Creates a substitution model, which consists
%   of Graph with substitution rules.

p = create_parser();
parse(p, varargin{:});

params = p.Results;

maxDistance = params.MaxDistance;
scoreFunction = params.ScoreFunction;

a = params.ScoreFunctionParam1;
b = params.ScoreFunctionParam2;

% Word2Vec-Model
m = D.m;

% Unigrams
w2v_u_i = D.Vi(~D.B);
w2v_u_i = w2v_u_i(w2v_u_i~=0);

dist_u = squareform(pdist(m.X(w2v_u_i,:),'cosine'));
dist_u(dist_u > 1) = 1;

likelihood = zeros(size(w2v_u_i,1),1);

% Frequencies of unigrams
F = D.termFrequencies();
F_u = F(~D.B & D.Vi ~= 0,:);

C = cell(numel(w2v_u_i),1);

edges = [];
for i=1:size(C,1)
    C{i} = find(dist_u(i,:) <= maxDistance);
    
    % Frequencies of current word
    k1 = F_u.PDocs(i) + 1;
    n1 = k1 + F_u.NDocs(i) + 1;
    p1 = k1/n1;
    
    curr_edges = [ repmat(i,numel(C{i}),1) C{i}' double(dist_u(i,C{i})')];
    
    %% This computation for each iteration of the cluster merging
    % Get frequencies of all target words
    K2 = F_u.PDocs(curr_edges(:,2)) + 1;
    N2 = K2 + F_u.NDocs(curr_edges(:,2)) + 1;
    P2 = K2./N2;
    
    % Max. Likelihood of current word
    L1 = p1^k1*(1-p1)^(n1-k1);
    likelihood(i) = L1;
    
    % Max. Likelihood of target words
    L2 = P2.^K2 .* (1-P2).^(N2-K2);
    
    % Max. joint likelihood
    L = L1*L2;
    
    % Probability of new model (After substitution)
    P_ = (k1 + K2)./(n1 + N2);
    
    % Likelihood of merged model
    L_ = P_.^(k1+K2).*(1-P_).^(n1-k1+N2-K2);
    
    pL_ = L_ ./ (L + L_);
    
    
    edges = [edges; [ curr_edges pL_]]; %#ok<AGROW>
end

edgesScore = scoreFunction(edges(:,4), edges(:,3),a,b);
edgesTable = table(edges(:,1:2),'VariableNames', {'EndNodes'});
edgesTable.Weight = edgesScore;

d = digraph(edgesTable);
A = wadjacency(d);
g = graph(A,d.Nodes,'lower','OmitSelfLoops');
clear d

edgesTableSorted = sortrows(g.Edges, 'Weight', 'ascend');
edgesTable = g.Edges;
clusters = 1:sum(~D.B & D.Vi ~= 0);

V = D.V(~D.B & D.Vi~=0);
mergeThreshold = 0.6;
while true
    edge = edgesTableSorted(1,:);
    
    if edge.Weight < mergeThreshold
        c1 = edge.EndNodes(1);
        c2 = edge.EndNodes(2);
        fprintf('c1: \n');
        V(c1 == clusters)
        
        fprintf('c2: \n');
        V(c2 == clusters)
        
        [clusters, edgesTable] = mergeClusters( g, edgesTable, clusters, c1, c2, F_u, dist_u, likelihood, scoreFunction, a, b );
        g = graph(edgesTable, 'OmitSelfLoops');
        edgesTable = g.Edges;
        edgesTableSorted = sortrows(edgesTable, 'Weight', 'ascend');
    else
        break;
    end
end

end

function d = clusterDistance(clusters,c1,c2,F_u,dist_u,likelihood,scoreFunction,a,b)
%nodes of first cluster
v1 = find(clusters==c1);
v2 = find(clusters==c2);
V = [v1 v2];

% Max Likelihood
L = prod(likelihood(V));

% Likelihood of model with substitutions
K = sum(F_u.PDocs(V) + 1);
N = sum(F_u.NDocs(V) + 1) + K;
P_ = K/N;

L_ = P_^K*(1-P_)^(N-K);

pL_ = L_ / (L + L_);

maxD = max(max(dist_u(V,V)));

d = scoreFunction(pL_, maxD);
end

function [clusters, edgesTable] = mergeClusters(g, edgesTable, clusters, c1, c2, F_u, dist_u,likelihood,scoreFunction,a,b)
neigh_c1 = neighbors(g, c1);
neigh_c2 = neighbors(g, c2);
C = setdiff(unique([neigh_c1; neigh_c2]), [c1; c2]);
clusters(c2 == clusters) = c1;

newEdges = zeros(numel(C), 3);
for i=1:numel(C)
    d = clusterDistance(clusters, c1, C(i),F_u,dist_u,likelihood,scoreFunction,a,b);
    newEdges(i,:) = [c1 C(i) d];
end

S1 = repmat(c1, 1, numel(neigh_c1));
T1 = neigh_c1;

S2 = repmat(c2, 1, numel(neigh_c2));
T2 = neigh_c2;

edges_c1 = findedge(g,S1,T1);
edges_c2 = findedge(g,S2,T2);
oldEdges = unique([edges_c1; edges_c2]);
edgesTable(oldEdges ,:) = [];
edgesTable = [edgesTable; table(newEdges(:,1:2), newEdges(:,3), 'VariableNames', {'EndNodes', 'Weight'})];
end

function p = create_parser()
p = inputParser;
p.KeepUnmatched = true;

% Algorithm Parameters
addParameter(p, 'MaxDistance', 0.4, @(x) x > 0);
addParameter(p, 'ScoreFunction', @(pL_,dists,a,b) (2*pL_).^a.*dists.^b, @(x) isa(x, 'function_handle'));
addParameter(p, 'ScoreFunctionParam1', 1.3, @(x) true);
addParameter(p, 'ScoreFunctionParam2', 0.7, @(x) true);
end