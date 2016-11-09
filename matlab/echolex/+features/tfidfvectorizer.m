function [ Y ] = tfidfvectorizer( X, W )
%TFIDFVECTORIZER Summary of this function goes here
%   Detailed explanation goes here

if size(W,2) ~= size(X,1)
    error('Vector Space Model X must contain as many rows as words (columns of W)');
end

Y = zeros(size(W,1), size(X,2));

for i=1:size(W,1)
    w = W(i,:);
    b = find(w);
    w = full(W(i,b));
    y = sum( bsxfun(@times, w', X(b,:)) ) ./ sum(w);
    Y(i,:) = y;
end


end

