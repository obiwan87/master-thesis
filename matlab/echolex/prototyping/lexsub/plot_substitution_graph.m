function h = plot_substitution_graph( d )
%PLOT_TERMS_GRAPH Summary of this function goes here
%   Detailed explanation goes here

if sum(strcmp('Weight', fieldnames(d.Edges))) > 0
    edgelabels = arrayfun(@(x) sprintf('%.2f', x), d.Edges.Weight, 'UniformOutput', false);
else
    edgelabels = {};
end

nodelabels = arrayfun(@(x) sprintf('%s (%d)', d.Nodes.Term{x}, d.Nodes.Frequency(x)), 1:numnodes(d), 'UniformOutput', false);

h = plot(d, 'EdgeLabel', edgelabels, 'NodeLabel', nodelabels, 'Layout','layered');

end

