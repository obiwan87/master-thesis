function [dist_u, pL_] = calculate_unigrams_distances(D, useGpu, cutAfterOne)

if nargin < 2
    useGpu = false;
end

if nargin < 3
    cutAfterOne = true;
end

% Word2Vec-Model
m = D.m;

% Unigrams
if ~isempty(D.B)
    w2v_u_i = D.Vi(~D.B);
else
    w2v_u_i = D.Vi;
end
w2v_u_i = w2v_u_i(w2v_u_i~=0);

X = m.X(w2v_u_i,:);
if ~useGpu
    dist_u = double(squareform(pdist(double(X),'cosine')));
else
    dist_u = double(gather(squareform(pdist(gpuArray(X),'cosine'))));
end

if cutAfterOne
    dist_u(dist_u > 1) = 1;
end

end