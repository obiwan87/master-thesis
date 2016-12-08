function sd = make_substitution_graph(d, substitutes)
edges = [];

for i=1:size(substitutes,2)-1
    s = unique(substitutes(:,i));
    
    for j=1:numel(s)
        t = substitutes(s(j),i+1);
        edge = [s(j) t];
        edges = [edges; edge];
    end
end

EdgeTable = table(edges(:,1), edges(:,2), 'VariableNames', {'source', 'target'});
EdgeTable = unique(EdgeTable);
EdgeTable = table([EdgeTable.source EdgeTable.target], 'VariableNames', {'EndNodes'});
sd = digraph(EdgeTable, 'OmitSelfLoops');
sd.Nodes = d.Nodes;
end
