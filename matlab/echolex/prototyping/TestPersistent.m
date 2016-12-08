classdef TestPersistent < handle
    %TESTPERSISTENT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function r = test(~, t)
            persistent p
            fprintf('Before assignment: %d', p);
            p = t;
            r = t;
        end
    end
    
end

