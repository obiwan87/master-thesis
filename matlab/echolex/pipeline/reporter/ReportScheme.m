classdef ReportScheme < handle
    %REPORTSCHEME Summary of this class goes here
    %   Detailed explanation goes here
    
    properties        
        Scheme
    end
    
    methods
        function obj = ReportScheme(varargin)
            obj.Scheme = varargin;
        end
        
        function r = report(obj, step, out)
            r = struct();
            % Find if any of the classes in the scheme definitions match
            % the current step's class.
            idx = find(arrayfun(@(x) sum(strcmp(class(step), obj.Scheme{x})) > 0, 1:numel(obj.Scheme)));
            
            if ~isempty(idx)                
                assignments = obj.Scheme{idx+1};
                                
                for i=2:2:numel(assignments)
                    varname = assignments{i-1};
                    varpath = assignments{i};
                    varpath = strsplit(varpath, '.');
                    
                    val = [];
                    s = out;
                    
                    found = true;                    
                    for j=1:numel(varpath)
                       p = varpath{j};
                       
                       if ( ~isstruct(s) && ~isobject(s) ) || sum(strcmp(p,fieldnames(s))) <= 0
                           val = [];
                           found = false;
                           break;
                       end
                       val = s.(p);
                       
                       s = val;
                    end
                    
                    if ~found
                        r.(varname) = val;
                    end
                end                                
            end
        end
        
    end
    
end

