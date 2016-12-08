WP = io.Word2VecDocumentSet(m, W.T(W.Y == 1), ones(sum(W.Y==1), 1));
WN = io.Word2VecDocumentSet(m, W.T(W.Y == 0), zeros(sum(W.Y==0), 1));

