classdef Pipeline < handle
    %PIPELINE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        RootSequence
        
        % Save outputs of nodes for later use
        Outputs
        
        Reporter = []; % Report outputs of nodes
        
        % Graph Information
        Graph
        PGraph
        InDegree
        OutDegree
        
        % Execution State
        ExecutionPaths = {};
        CurrentExecutionPath = 1;
        CurrentStep
        
        %Verbose Output
        Padding = 0
        CharsWritten = 0
        MaxChild = 0
    end
    
    methods
        function obj = Pipeline(varargin)
            if numel(varargin) == 1 && isa(varargin{1}, 'pipeline.Sequence')
                obj.RootSequence = varargin{1};
            else
                obj.RootSequence = sequence(varargin{:});
            end
            
            obj.Outputs = containers.Map('KeyType', 'uint32', 'ValueType', 'any');
            obj.PGraph = pipeline.PipelineGraph(obj);
            obj.Graph = obj.PGraph.createGraph();
            obj.InDegree = indegree(obj.Graph);
            obj.OutDegree = outdegree(obj.Graph);
            obj.CurrentStep = containers.Map('KeyType', 'uint32', 'ValueType', 'uint32');
            obj.CurrentStep(obj.CurrentExecutionPath) = 1;
        end
        
        function execute(obj, input, reporter)
            if nargin < 3
                reporter = [];
            end
            
            root = find(indegree(obj.Graph) == 0);
            obj.Reporter = reporter;
            
            start = tic;
            obj.dfexec(root, input, 1); %#ok<FNDSB>
            duration = toc(start);
            
            if ~isempty(obj.Reporter)
                obj.Reporter.Duration = duration;
                obj.Reporter.normalize();
            end
        end
        
        function dfexec(obj, parent, input, depth)
            children = successors(obj.Graph, parent);
            
            if isempty(children)
                obj.CurrentExecutionPath = obj.CurrentExecutionPath + 1;
            end
            
            for i=1:numel(children)
                node = children(i);
                step = obj.PGraph.Steps(node);
                
                % Just for debugging purposes and progress purposes
                
                if i > 1
                    padding = repmat(' ', obj.Padding, 1);
                else
                    padding = '';
                end
                
                output = sprintf('%s-> %s', padding, shortclass(step));
                
                previousPadding = obj.Padding;                
                obj.Padding = obj.Padding + length(output);
                
                fprintf(output);
                
                start = tic;
                out = step.execute(obj, input);                
                duration = toc(start);
                
                if ~isempty(obj.Reporter)
                    obj.Reporter.report(step, input, out, obj.CurrentExecutionPath, depth, duration);
                end
                
                if step.SaveOutput
                    obj.Outputs(node) = out;
                end

                obj.dfexec(node, out.Out, depth + 1);
                
                obj.Padding = previousPadding;
                fprintf('\n');
            end
        end
        
        function plot(obj)
            renderer = pipeline.PipelineRenderer(obj);
            plot(renderer);
        end
    end
    methods(Access=private)
        function newExecutionPath(obj)
            obj.CurrentExecutionPath = obj.CurrentExecutionPath + 1;
        end
    end
end