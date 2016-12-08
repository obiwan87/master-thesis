classdef PipelineRenderer < handle
    %PIPELINERENDERER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        P
        Edges
        Nodes
        EdgeLabels
        NodeLabels
        N
        Graph
    end
    
    properties(Hidden)
        fcn
    end
    methods
        function obj = PipelineRenderer(P)
            obj.P = P;
        end
        
        function prepare(obj)
            pgraph = obj.P.PGraph();
            root = 1;
            obj.N = root;
            pgraph.createGraph(root);
            
            obj.Graph = digraph();
            theirroot = pgraph.Root;
            obj.dfs(pgraph, theirroot, root);
            
            [obj.Edges, ii] = sortrows(obj.Edges, [1 2]);
            obj.EdgeLabels = obj.EdgeLabels(ii);
        end
        
        function plot(obj)
            if isempty(obj.Graph)
                obj.prepare();
            end
            obj.fcn = @(label) label(find(isstrprop(label, 'upper'), 4,'first'));
            
            
            labels = cellfun(obj.fcn, obj.EdgeLabels, 'UniformOutput', false);
            plot(obj.Graph, 'Layout', 'Layered', 'EdgeLabel', labels);
            
            obj.createLegend();
            ax = gca;            
            ax.XTick = [];
            ax.XTickLabel = [];
            
            fig = gcf;
            fig.Color = 'w';
            axis(ax, 'off');
            
            set(ax, 'FontSize', 8);
        end
        
        function createLegend(obj)
            labels = unique(obj.EdgeLabels);
            
            anns =  cell(numel(labels),1);
            
            for i=1:numel(labels)
                anns{i} = sprintf('\\textbf{%s}: %s', obj.fcn(labels{i}), labels{i});
            end
            
            txt = strjoin(anns, '\n');
            annotation('textbox', [0 0.8 0.2 0.2], 'String', txt, 'Interpreter', 'latex');
        end
        
        function dfs(obj, pgraph, theirparent, parent)
            graph = pgraph.Graph;
            s = successors(graph, theirparent);
            
            for i=1:numel(s)
                obj.N = obj.N + 1;
                child = s(i);
                step = pgraph.Steps(child);
                
                edge = [parent  obj.N];
                addedge(obj, step, edge);
                
                if isa(step, 'pipeline.InputSelector')
                    subpgraph = step.Pipeline.PGraph;
                    obj.dfs(subpgraph, pgraph.Root, obj.N);
                    obj.N = obj.N + 1;
                    o = outdegree(obj.Graph);
                    outputs = find(o==0);
                    outputs = outputs(outputs > child);
                    
                    for j=1:numel(outputs)
                        addedge(obj, step, [outputs(j) obj.N]);
                    end
                end
                
                obj.dfs(pgraph, child, obj.N);
            end
        end
        
        function addedge(obj, step, edge)
            obj.Edges = [obj.Edges; edge];
            label = shortclass(step);
            obj.EdgeLabels{end+1} = label;
            
            obj.Graph = addedge(obj.Graph, edge(1), edge(2));
        end
    end
end

