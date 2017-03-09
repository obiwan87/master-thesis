classdef GraphLexicalSubstitution < LexicalSubstitutionPreprocessor
    %GRAPHLEXICALSUBSTITUTION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        K
        Iterations
        SubstitutionThreshold
    end
    
    methods
        function obj = GraphLexicalSubstitution(varargin)
            obj = obj@LexicalSubstitutionPreprocessor(varargin{:});
        end
        
        function d = makeGraph(~, W,K)
            
            if nargin < 2
                K = 5;
            end
            
            Vi = W.Vi(W.Vi~=0);
            ref = W.m.X(Vi,:);
            query = ref;
            [nns, dist] = gknnsearch(ref,query,K,true,false);
            
            N = repmat(1:size(Vi,1), K, 1);
            
            % Generate adjeciency matrix
            A = sparse(N', nns(:), dist(:), size(nns,1), size(nns,1));
            F = W.termFrequencies();
            d = digraph(A);
            
            d.Nodes.Frequency = F.Frequency(W.Vi~=0);
            d.Nodes.Term = F.Term(W.Vi~=0);;
            d.Nodes.TermIdx = (1:numel(Vi))';
            d.Nodes.GlobalFrequency = W.m.Frequencies(Vi);
        end
        
        function r = doExecute(obj, ~, args)
            
            D = args.DocumentSet;
            d = obj.makeGraph(D, obj.K);
            
            substitutes = obj.graphSubstitution(d, obj.Iterations);
            nZ = find(D.Vi ~= 0);
            
            S = 1:numel(D.V);
            S(nZ) = nZ(substitutes(:,end));
            
            LI = cellfun(@(x) S(x), D.I, 'UniformOutput', false);
            LT = cellfun(@(x) D.V(x)', LI, 'UniformOutput', false);
            LD = io.Word2VecDocumentSet(D.m, LT, D.Y);
            LD.tfidf();
            r = struct('Out', LD);
            info = struct();
            info.vocSizeBefore = numel(D.V);
            info.vocSizeAfter = numel(LD.V);
            info.LVi = S;
            
            r.info = info;
            % Create document set with substituted games
        end
        
        function [substitutes, graphs] = graphSubstitution(~, d, iterations)
            
            ld = d; % Nodes are annotated with frequency and term (string)
            substitutes = zeros(numnodes(ld), iterations+1);
            substitutes(:,1) = 1:numnodes(ld);
            
            graphs = cell(iterations, 1);
            i = 1;
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
                        % Substitute every node in current connected
                        % component
                        
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
    end
    
    methods (Access = protected)
        function p = createPipelineInputParser(obj)
            p = createPipelineInputParser@pipeline.AtomicPipelineStep(obj);
            
            % Pipeline Input (=Dataset)
            addRequired(p, 'DocumentSet', @(x) isa(x, 'io.DocumentSet'));
        end
        
        function p = createConfigurationInputParser(obj)
            p = createConfigurationInputParser@pipeline.AtomicPipelineStep(obj);
            
            % Algorithm Parameters
            addParameter(p, 'K', 10, @is_pos_integer);
            addParameter(p, 'SubstitutionThreshold', Inf, @(x) x > 0);
            addParameter(p, 'Iterations', 10, @is_pos_integer);
            
            function b = is_pos_integer(x)
                b = isscalar(x) && x >= 1 && floor(x) == x;
            end
        end
        
        function config(obj, args)
            config@pipeline.AtomicPipelineStep(obj, args);
            
            obj.K = args.K;
            obj.SubstitutionThreshold = args.SubstitutionThreshold;
            obj.Iterations = args.Iterations;
        end
    end
    
end

