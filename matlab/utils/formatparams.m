function [ args ] = formatparams( valdelim, paramdelim, params)
%FORMATPARAMS Summary of this function goes here
%   Detailed explanation goes here

argNames = params(1:2:end);
argValues = params(2:2:end);
argValues = cellfun(@(x) str(x), argValues, 'UniformOutput', false);

args = {argNames{:}; argValues{:}};
args = arrayfun(@(x) sprintf('%s%s''%s''', args{1,x}, valdelim, args{2,x}), 1:size(args,2), 'UniformOutput', false);
args = strjoin(args, paramdelim);

end

