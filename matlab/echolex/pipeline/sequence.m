function [ S ] = sequence( varargin )
%SEQUENCE Syntactic sugar for creation of sequences

if numel(varargin) == 1 && iscell(varargin{1})
    args = varargin{1};
else
    args = varargin;
end
S = pipeline.Sequence(args{:});

end

