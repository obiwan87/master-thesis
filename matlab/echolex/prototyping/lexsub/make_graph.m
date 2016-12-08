function d = make_graph(W, K)

if nargin < 2
    K = 5;
end

ref = W.m.X(W.Vi,:);
query = ref;
[nns, dist] = gknnsearch(ref,query,K,true,false);

N = repmat(1:size(W.V,1), K, 1);

% Generate adjeciency matrix
A = sparse(N', nns(:), dist(:), size(nns,1), size(nns,1));
F = W.termFrequencies();
d = digraph(A);

d.Nodes.Frequency = F.Frequency;
d.Nodes.Term = F.Term;
d.Nodes.TermIdx = (1:numel(W.V))';
d.Nodes.GlobalFrequency = W.m.Frequencies(W.Vi);

end