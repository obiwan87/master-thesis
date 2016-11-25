classdef DataLabelProvider < pipeline.io.DataProvider & pipeline.io.LabelProvider
    %DATALABELPROVIDER Summary of this class goes here
    %   Detailed explanation goes here
    
    methods
        function obj = DataLabelProvider(data, labels)
            obj.Data = data;
            obj.Labels = labels;
        end                
        
        function o = compact(~)
            o = [];
        end
    end
    
end

