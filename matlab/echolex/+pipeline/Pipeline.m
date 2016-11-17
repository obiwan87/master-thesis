classdef Pipeline < handle
    %PIPELINE Summary of this class goes here
    %   Detailed explanation goes here
           
    properties
        Steps
        ExecutionPaths
    end    
    
    methods
        function obj = Pipeline(varargin)
            obj.Steps = varargin;
        end
        
        function calculateExecutionPaths(obj)
            obj.ExecutionPaths = {};
            obj.sequence(obj.Steps, 1, 1);
        end
        
        function npathNr = sequence(obj, S, pathNr, stepNr)                                    
            for i=1:numel(S)
                s = S{i};
                if iscell(s)
                    npathNr = obj.fork(s, pathNr, stepNr);
                else 
                    obj.ExecutionPaths{pathNr, stepNr} = s; 
                end
                stepNr = stepNr + 1;
            end
            npathNr = pathNr;
        end
        
        function npathNr = fork(obj, F, pathNr, stepNr)
            npathNr = pathNr - 1;
            for i=1:numel(F)
                npathNr = npathNr + 1;
                s = F{i,:};
                % Flattened, Fork Subset, Still to be flattened
                S = {s obj.Steps{stepNr+1:end}};            
                obj.ExecutionPaths(npathNr, 1:stepNr-1) = obj.ExecutionPaths(pathNr, 1:stepNr-1);
                npathNr = obj.sequence(S, npathNr, stepNr);
            end
        end
        
        function show(obj, step)
            function pname = simple_class(objekt)
                pname = strsplit(class(objekt), '.');
                pname = pname{end};
            end                        
            fprintf('-> %s', simple_class(step));
        end
    end
    
end