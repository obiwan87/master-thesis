function [ F ] = fork( varargin )
%FORK Syntactic sugar for creation of forks

if numel(varargin) == 1 && iscell(varargin{1})
    args = varargin{1};
else
    args = varargin;
end

nargs = args;
k = 1;
for j = 1:numel(args)
    if iscell(args{j})
        n = numel(args{j});
        nargs(k:(k+n-1)) = args{j}(:);
        k = k + n;
    else
        nargs(k) = args(j);
        k = k + 1;
    end
end
F = pipeline.Fork(nargs{:});

end

