function [ r ] = datalabelprovider( data, labels)
%DATALABELPROVIDER Syntactic sugar for creation of data label providers

r = pipeline.io.PacketFactory.createDataLabelProvider(data, labels);

end

