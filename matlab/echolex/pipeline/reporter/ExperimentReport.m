classdef ExperimentReport < handle
    %BASICREPORTER Reports the arguments and the output of each step
    %   Detailed explanation goes here
    properties
        ExperimentId
        Date
        Dataset
        Name
        Description
        Steps = {}
        Duration
    end
    
    properties(Hidden)
        scheme
    end
    
    methods(Static)
        function obj = fromStruct(s)
            obj = ExperimentReport();
            obj.ExperimentId = s.ExperimentId;
            obj.Dataset = s.Dataset;
            obj.Name = s.Name;
            obj.Description = s.Description;
            obj.Date = s.Date;
            obj.Steps = {};
            obj.Duration = s.Duration;
            
            for i = 1:numel(s.Steps)
                sr = numel(s.Steps{i});
                obj.Steps(i,1:sr) = s.Steps{i}(:);
            end
        end
    end
    methods
        function obj = ExperimentReport(experimentId, dataset, experimentName, description, scheme)
            
            if nargin == 0
                return
            end
            
            if nargin < 5
                scheme = [];
            end
            
            obj.ExperimentId = experimentId;
            obj.Dataset = dataset;
            obj.Name = experimentName;
            obj.Description = description;
            obj.Date = datestr(datetime());
            obj.scheme = scheme;
        end
        
        function c = cloneWithoutSteps(obj)
            c = ExperimentReport(obj.ExperimentId, obj.Dataset, obj.Name, obj.Description, obj.scheme);
        end
        
        function report(obj, step, ~, out, pathNr, stepNr, duration)
            r = struct();
            r.Name = shortclass(step);
            
            r.Args = cellfun(@(x) ife(isa(x,'function_handle'), str(x), x), step.Args, 'UniformOutput', false);
            r.Args = varargin2struct(r.Args{:});
            r.Duration = duration;
            r.PathNr = pathNr;
            r.StepNr = stepNr;
            
            if any(strcmp('Report', fieldnames(out)))
                r.Report = out.Report;
            end
            
            if strfind(class(step), 'Classifier')
                r.Out = out;
            end
            
            if ~isempty(obj.scheme)
                %additional information
                info = obj.scheme.report(step, out);
                r = mergestruct(r,info);
            end
            
            obj.Steps{pathNr, stepNr} = r;
        end
        
        function normalize(obj)
            for j=2:size(obj.Steps)
                steps =obj.Steps(j,:);
                for k=1:numel(steps)
                    if isempty(steps{k})
                        obj.Steps{j,k} = obj.Steps{j-1,k};
                    else
                        break;
                    end
                end
            end
        end
        
        function t = table(obj, sessionNr)
            session = obj.Sessions{sessionNr};
            report = session.Report;
            
            c = cell(size(report));
            for j=1:size(report,1)
                for k=1:numel(report(j,:))
                    s = report{j,k};
                    if ~isempty(s)
                        argNames = s.Args(1:2:end);
                        argValues = s.Args(2:2:end);
                        argValues = cellfun(@(x) str(x), argValues, 'UniformOutput', false);
                        
                        args = {argNames{:}; argValues{:}};
                        args = arrayfun(@(x) sprintf('%s: %s', args{1,x}, args{2,x}), 1:size(args,2), 'UniformOutput', false);
                        args = strjoin(args, ', ');
                        
                        c{j,k} = sprintf('%s=[%s]', s.Name, args);
                        
                        if strfind(s.Name, 'Classifier')
                            c{j,k} = sprintf('%s{loss: %.2f %%}',c{j,k}, s.Out.loss*100);
                        end
                    else
                        c{j,k} = '*';
                    end
                end
            end
            
            variableNames = arrayfun(@(x) sprintf('Step_%d',x), 1:size(report,2), 'UniformOutput', false);
            t = cell2table(c, 'VariableNames', variableNames);
        end
        
        function plot(obj)
            % Transform execution to directed graph
            d = digraph();
            
            nids = zeros(size(obj.Steps));
            root = 1;
            n = 2;
            
            pnid = root;
            edgeLabels = {};
            nodeLabels = {'Input'};
            edges = [];
            for i=1:size(obj.Steps,1)
                steps = obj.Steps(i,:);
                for j=1:numel(steps)
                    step = steps{j};
                    if ~isempty(step)
                        nids(i,j) = n;
                        
                        if ~isempty(pnid)
                            d = addedge(d, pnid, n);
                            edges = [edges; pnid n]; %#ok<AGROW>
                            edgeLabels{end+1} = formatparams(': ', ', ', struct2params(step.Args)); %#ok<AGROW>
                        end
                        
                        nodeLabels{end+1} = step.Name; %#ok<AGROW>
                        n = n + 1;
                    else
                        nids(i,j) = nids(i-1,j);
                    end
                    pnid = nids(i,j);
                end
                pnid = root;
            end
            
            [~, ii]= sortrows(edges, [1 2]);
            edgeLabels = edgeLabels(ii);
            
            fig = figure;
            plot(d, 'NodeLabel', nodeLabels);%, 'EdgeLabel', edgeLabels);
            ax = fig.CurrentAxes;
            ax.XTickLabel = '';
            ax.XTick = [];
            ax.YTickLabel = '';
            ax.YTick = [];
        end
        
    end
    
end

