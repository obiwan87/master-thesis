function [substitutes, graphs] = graph_substitution(d, iterations)

i = 1;
ld = d; % Nodes are annotated with frequency and term (string)
substitutes = zeros(numnodes(ld), iterations+1);
substitutes(:,1) = 1:numnodes(ld);

graphs = cell(iterations, 1);

while i <= iterations
    
    % Get connected component
    % Find out which node to merge with
    % Replace node in graph
    % Update frequencies
    C = conncomp(ld, 'Type', 'weak'); %How does 'Type' affect substitutions?
    % ^ It probably doesnt. It just speeds up computation since distances
    % can be computed with bigger batches
    cs = unique(C);

    freq = ld.Nodes.Frequency';
    tic
    for j=1:numel(cs)
        %fprintf('%d: %s \n', j, W.V{ld.Nodes.TermIdx(j)});
        nodes = find(C==cs(j));
        
        if numel(nodes) > 1
            % Calculate reward of subsituting term
            wdistances = distances(ld, nodes, nodes, 'Method', 'positive');
            udistances = distances(ld, nodes, nodes, 'Method', 'unweighted');
            
            idx = sub2ind(size(udistances), 1:numel(nodes), 1:numel(nodes));
            udistances(idx) = 1; % Set distance to node itself to 1
            
            
            gdist = udistances + wdistances;
            reward = (1./gdist.^2) .* sqrt(freq(nodes));
            bestNodes = maxi(reward,[],2);
            bestNodes = nodes(bestNodes);
            substitute = ld.Nodes.TermIdx(bestNodes); % Which nodes have the best reward?
            substitutes(nodes, i+1) = substitute;
        else
            substitutes(nodes, i+1) = substitutes(nodes, i);
        end
    end
    toc
    %nz = substitutes(nodes, i+1) ~= 0;
    nodes = (1:numnodes(ld))';
    %nodes = nodes(nz);
    
    % Resolve transitive substitutions A -> B -> C => A -> C
    edges = table(substitutes(:,i+1), nodes, 'VariableNames', {'source', 'target'});
    edges = unique(edges);
    edges = table([edges.source edges.target], 'VariableNames', {'EndNodes'});
    sd = digraph(edges, ld.Nodes, 'OmitSelfLoops');        
    
    % If we encounter cycles, then something went wrong
    assert(isdag(sd));
    
    % Each connected component represent a substitution 
    C = conncomp(sd, 'type', 'weak');
    cs = unique(C);
    nodesInComp = histc(C,cs);    
    
    nn = numnodes(ld);    
    [s,t] = findedge(ld);
    A = sparse(s,t,ld.Edges.Weight,nn,nn);
    
    for j=1:numel(cs)
        if nodesInComp(j) > 2
            snodes = find(cs(j) == C);
            tg = transclosure(subgraph(sd, snodes));
            
            % Establish root and its children of this substitution graph 
            % (=tree)
            
            root = snodes(indegree(tg) == 0);
            assert(numel(root) == 1); 
            children = setdiff(snodes, root);
            
            A(root,:) = mean(A(snodes,:)); %#ok<*SPRIX>
            A(:, root) = mean(A(:,snodes), 2);
            
            A(children, :) = 0;
            A(:, children) = 0;
            
            substitutes(children, i+1) = root;
            
            freq(root) = sum(ld.Nodes.Frequency(children));
            freq(children) = 0;            
        end
    end    
    
    ld = digraph(A);
    ld = digraph(ld.Edges, d.Nodes);
    ld.Nodes.Frequency = freq';
    
    graphs{i} = ld;
    i = i + 1;
end
end

