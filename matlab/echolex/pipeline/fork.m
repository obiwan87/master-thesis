function [ F ] = fork( varargin )
%FORK Syntactic sugar for creation of forks

if numel(varargin) == 1 && iscell(varargin{1})
    args = varargin{1};
else
    args = varargin;
end
F = pipeline.Fork(args{:});

end

