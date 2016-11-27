classdef PipelineGraph < handle
    %PIPELINEGRAPH Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Pipeline
        
        Steps
        LastNodeStack = {};
        
        Nodes = [];
        Edges = [];
        
        Node = 2;
        Root = 1
    end
    
    properties(Access=public)
        Graph % Graph
    end
    
    methods
        function obj = PipelineGraph(pipeline)
            obj.Steps = containers.Map('KeyType', 'uint32', 'ValueType', 'any');
            obj.Pipeline = pipeline;
        end
        
        function g = createGraph(obj, root)
            rootSequence = obj.Pipeline.RootSequence;
            obj.Graph = digraph();
            obj.Nodes = [];
            obj.Edges = [];
            
            if nargin < 2
                root = 1;
            end
            obj.Root = root;
            obj.pushNode(root);
            obj.Node = uint32(root + 1);
            
            obj.sequence(rootSequence);
            
            for i=1:size(obj.Edges, 1)
                obj.Graph = addedge(obj.Graph, obj.Edges(i,1), obj.Edges(i,2));
            end
            
            g = obj.Graph;
        end
        
        function sequence(obj, S)
            prevS = [];
            s = S.Children{1};
            p = s;
            while ~isempty(p)
                while s ~= pipeline.EOP.getInstance
                    if isa(s, 'pipeline.Fork')
                        obj.fork(s);
                        return
                    elseif isa(s, 'pipeline.Sequence')
                        obj.sequence(s);
                        return
                    elseif isa(s, 'pipeline.Select')
                        
                        previousNode = obj.popNode();
                        obj.Edges = [obj.Edges; previousNode obj.Node];
                        
                        selector = s.createSelector();
                        obj.Steps(obj.Node) = selector;
                        obj.pushNode(obj.Node);
                        obj.Node = obj.Node + 1;
                        %return
                    elseif isa(s,'pipeline.AtomicPipelineStep')
                        % Update execution state
                        previousNode = obj.popNode();
                        obj.Edges = [obj.Edges; previousNode obj.Node];
                        
                        obj.Steps(obj.Node) = s;
                        
                        obj.pushNode(obj.Node);
                        obj.Node = obj.Node + 1;
                    else
                        error('Pipeline Step not supported: %s', class(s))
                    end
                    
                    prevS = s;
                    s = s.NextStep;
                end
                % Ok, this is kind of tricky.
                % Switch Context: Assume parent node
                % has been executed. So get next step of parent
                % and set parent to be the previous step.
                p = prevS.Parent;
                prevS = p;
                if ~isempty(p)
                    s = p.NextStep;
                end
            end
        end
        
        function fork(obj, F)
            % Each child is a branch
            currentNode = obj.popNode();
            for i=1:numel(F.Children)
                
                obj.pushNode(currentNode);
                S = F.Children{i}.asSequence();
                obj.sequence(S);
                
                fprintf('*\n');
            end
        end
        
        function pushNode(obj, N)
            obj.LastNodeStack{end+1} = N;
            obj.Nodes = unique([obj.Nodes N]);
        end
        
        function n = popNode(obj)
            n = obj.LastNodeStack{end};
        end
    end
    
end

