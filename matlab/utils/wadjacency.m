function [ A ] = wadjacency( d )
%WADJECENCY Weighted adjacency matrix
%   Detailed explanation goes here

nn = numnodes(d);
[s,t] = findedge(d);
A = sparse(s,t,d.Edges.Weight,nn,nn);

end

