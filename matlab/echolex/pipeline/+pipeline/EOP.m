classdef (Sealed) EOP < pipeline.AtomicPipelineStep
    %EOP End of Pipeline (Magic Object)
    
    methods(Static)
        function singleObj = getInstance
            persistent localObj
            if isempty(localObj) || ~isvalid(localObj)
                localObj = pipeline.EOP;
            end
            singleObj = localObj;
        end
    end
    
    methods(Access = private)
        function obj = EOP()
        end
        
    end
    
    methods(Access = public)        
        function r = doExecute(~, ~)
            r = 0;
        end
    end
    
end

