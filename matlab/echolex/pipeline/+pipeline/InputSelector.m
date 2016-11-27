classdef InputSelector < pipeline.AtomicPipelineStep
    %INPUTSELECTOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        ObjectiveFunction
        Children
        Pipeline
    end
    
    methods
        function obj = InputSelector(children, objectiveFunction)
            obj.Children = children; %pipeline
            obj.ObjectiveFunction = objectiveFunction;
            obj.Pipeline = pipeline.Pipeline(obj.Children{:});
        end
        
        function r = doExecute(obj, context, args)
            input = args.Input;
            P = obj.Pipeline;
            reporter = context.Reporter;
            
            if ~isempty(reporter)
                reporter = reporter.cloneWithoutSteps();
            end
            
            P.execute(input, reporter);
            pipelineOutputs = find(P.OutDegree == 0);
            pipelineOutputs = arrayfun(@(n) P.Outputs(n), pipelineOutputs, 'UniformOutput', false);
            
            pipelineInputs = successors(P.Graph, P.PGraph.Root);
            pipelineInputs = arrayfun(@(n) P.PGraph.Steps(n), pipelineInputs, 'UniformOutput', false);
            
            selectedIndex = obj.ObjectiveFunction(pipelineOutputs); 
            step = pipelineInputs{selectedIndex};
            
            r = step.LastOutput;
            if ~isempty(reporter)
                r.Report = reporter;
            end
        end
        
        function pushInput(obj, input)
            obj.Input{end+1} = input;
        end
    end
    
    methods(Access = protected)
        function p = createPipelineInputParser(obj)
            p = createPipelineInputParser@pipeline.AtomicPipelineStep(obj);
            addRequired(p, 'Input', @(x) true);
        end
    end
    
end

