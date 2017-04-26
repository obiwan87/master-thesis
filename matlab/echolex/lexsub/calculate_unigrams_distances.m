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

% Frequencies of unigrams
F = D.termFrequencies();
F_u = F(~D.B & D.Vi ~= 0,:);

% Calculate likelihood of model if pairwise substituting each word
K = F_u.PDocs + 1;

if useGpu
    K = gpuArray(K);
end

N = K + F_u.NDocs + 1;
P = K./N;

L = P.^K.*(1-P).^(N-K);
L = L .* L';

k = K + K';
n = N + N';
P_ = k./n;
L_ = P_.^k.*(1-P_).^(n-k);
pL_ = L_ ./ (L + L_);
pL_(pL_>0.5) = 0.5; % due to numerical imprecision we might get values slightly over 0.5
if useGpu
    pL_ = gather(pL_);
end

end