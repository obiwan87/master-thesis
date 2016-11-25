classdef Pipeline < handle
    %PIPELINE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        RootSequence
        CurrentExecutionPath = 1;
        CurrentStep  = 1;
        ExecutionPaths = {};
        Outputs = {};
        LastFork = {1};
        Reporter = [];
        DoExecute = [];
    end
    
    methods
        function obj = Pipeline(varargin)
            if numel(varargin) == 1 && isa(varargin{1}, 'pipeline.Sequence')
                obj.RootSequence = varargin{1};
            else
                obj.RootSequence = sequence(varargin{:});
            end
        end
        
        function r = execute(obj, input, reporter, doExecute)
            if nargin < 3
                reporter = [];
            end
                        
            if nargin < 5
                doExecute = true;
            end
            
            obj.ExecutionPaths = {};
            obj.Reporter = reporter;
            obj.DoExecute = doExecute;
            
            start = tic;
            obj.sequence(input, obj.RootSequence);
            duration = toc(start);
            
            if ~isempty(obj.Reporter)
                obj.Reporter.Duration = duration;
            end
            
            r = reporter;
        end
        
        function sequence(obj, input, S)
            in = struct('Out', input);
            prevS = [];
            s = S.Children{1};
            p = s;
            while ~isempty(p)
                while s ~= pipeline.EOP.getInstance
                    if isa(s, 'pipeline.Fork')
                        obj.LastFork{end+1} = obj.CurrentStep;
                        obj.fork(in.Out, s);
                        fprintf('<EOF>\n');
                        return
                    elseif isa(s, 'pipeline.Sequence')
                        obj.sequence(in.Out, s);
                        return
                    elseif isa(s, 'pipeline.Select')
                        p = pipeline.Pipeline(s.Children{:});
                        
                        start = tic;
                        subReport = [];
                        if ~isempty(obj.Reporter)
                            subReport = obj.Reporter.cloneWithoutSteps();
                        end
                        
                        p.execute(in.Out, subReport);
                        duration = toc(start);
                        
                        % Get the best execution path
                        objSteps = cell(size(p.ExecutionPaths,1),1); 
                        outputs = cell(size(p.ExecutionPaths,1),1);
                        
                        % Gather results of all execution paths
                        for k=1:size(p.ExecutionPaths,1)
                            executionPath = p.ExecutionPaths(k,:);
                            idx = find(~cellfun(@isempty, executionPath),1,'last');                            
                            objSteps{k} = p.Outputs{k, idx};
                            
                            if isempty(p.ExecutionPaths{k,1})
                                p.ExecutionPaths{k,1} = p.ExecutionPaths{k-1,1};
                            end
                            
                            outputs{k} = p.ExecutionPaths{k,1};
                        end
                        
                        % Get index of best result according to passed
                        % objective function.
                        selectedIdx = s.ObjectiveFcn(objSteps);
                        
                        % This output step was selected
                        selectedOutputStep = outputs{selectedIdx};
                        obj.ExecutionPaths{obj.CurrentExecutionPath, obj.CurrentStep} = selectedOutputStep;
                        out = selectedOutputStep.LastOutput;
                        
                        if ~isempty(subReport)
                            out.Report = subReport;
                        end
                        
                        %Go on as if an atomic pipeline step was executed
                        if selectedOutputStep.SaveOutput
                            obj.Outputs{obj.CurrentExecutionPath, obj.CurrentStep} = out;
                        end
                        
                        if ~isempty(obj.Reporter)
                            obj.Reporter.report(selectedOutputStep, in, out, obj.CurrentExecutionPath, obj.CurrentStep, duration);
                        end
                        
                        obj.CurrentStep = obj.CurrentStep + 1;
                        
                    elseif isa(s,'pipeline.AtomicPipelineStep')
                        fprintf('%s -> ', class(s))
                        
                        if obj.DoExecute
                            start = tic;
                            out = s.execute(in.Out);
                            duration = toc(start);
                            
                            % Report results of this step
                            if ~isempty(obj.Reporter)
                                obj.Reporter.report(s, in, out, obj.CurrentExecutionPath, obj.CurrentStep, duration);
                            end
                        end
                        
                        if s.SaveOutput
                            obj.Outputs{obj.CurrentExecutionPath, obj.CurrentStep} = out;
                        end
                        
                        % Update execution state                        
                        obj.ExecutionPaths{obj.CurrentExecutionPath,obj.CurrentStep} = s;
                        obj.CurrentStep = obj.CurrentStep + 1;
                    else 
                        error('Pipeline Step not supported: %s', class(s))
                    end
                    
                    in = out;
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
            
            % Keep track of the current execution state
            obj.CurrentExecutionPath = obj.CurrentExecutionPath + 1;
            obj.CurrentStep = popLastFork(obj);
        end
        
        function lastFork = popLastFork(obj)
            lastFork = obj.LastFork{end};
            if numel(obj.LastFork) > 1
                obj.LastFork = obj.LastFork(1:end-1);
            end
        end
        
        function fork(obj, input, F)
            % Each child is a branch
            for i=1:numel(F.Children)
                S = F.Children{i}.asSequence();
                
                obj.sequence(input, S);
                fprintf('*\n');
            end
        end

        function reset(obj)
            obj.ExecutionPaths = {};
            obj.CurrentExecutionPath = 1;
            obj.CurrentStep  = 1;
            obj.LastFork = {1};
            obj.Reporter = [];
            obj.DoExecute = [];
        end
    end    
end