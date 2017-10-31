function [ P ] = bayes_hypothesis_probability( L, D, varargin )

if numel(varargin) < 2
   error('This function needs at least one parameter'); 
end

a = varargin{1};
b = varargin{2};
if a > 0
    % Calculate priors from distances
    d = a/2*(D-1)+0.5;
    d = 1./d - 1;
else 
    % Assume priors are uniform
    d = 1;
end

if b > 0
P = 1+L.*d;
clear d
P = b./P;
else
    P = 0;
end

if b == 1
    D = 0;
end

P = P  + (1-b)*D/2;

end

