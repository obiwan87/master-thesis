function S = minkowski(X,p,dim)
    S = X.^p;
    S = sum(S,dim);
    S = S.^(1/p);
end
