classdef Reporter < handle
    %REPORTER Abstract class for Reports of pipeline results.
    
    methods(Abstract)
        report(obj, step, in, out, pathNr, stepNr, duration);
    end
    
end
