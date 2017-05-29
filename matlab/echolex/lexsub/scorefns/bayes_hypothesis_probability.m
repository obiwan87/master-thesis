function [ P ] = bayes_hypothesis_probability( L, D, varargin )

if numel(varargin) < 2
   error('This function needs at least one parameter'); 
end

a = varargin{1};
b = varargin{2};
if a > 0
    % Calculate priors from distances
    d = a/2*(D-1)+0.5;
    d = (1-d)./d;
else 
    % Assume priors are uniform
    d = 1;
end

P = 1+L.*d;
clear d
P = 1./P;
P = b*P  + (1-b)*D/2;
end

