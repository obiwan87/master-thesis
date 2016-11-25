classdef PacketFactory
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods(Static)
        function r = createDataLabelProvider(data, labels)
            r = pipeline.io.DataLabelProvider(data, labels);
        end
    end
    
end

