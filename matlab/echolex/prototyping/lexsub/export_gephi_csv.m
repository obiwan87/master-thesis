function export_gephi_csv(d, nodesPath, edgesPath )
%EXPORT_GEPHI_CSV Summary of this function goes here
%   Detailed explanation goes here

edges = d.Edges;
edges.source = d.Edges.EndNodes(:,1);
edges.target = d.Edges.EndNodes(:,2);
edges.Properties.VariableNames = lower(edges.Properties.VariableNames);

writetable(d.Nodes, nodesPath);
writetable(edges, edgesPath);

end


