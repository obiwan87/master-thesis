function [ g ] = neighborhood( g, nodeID, n )

d = distances(g, nodeID, 'Method', 'unweighted');
nodes = find(d <= n);

g = subgraph(g, nodes);

end

