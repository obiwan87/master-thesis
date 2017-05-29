function D = save_mem

X = 1:10;
D = pdist(X',@distfun);
    function d2 = distfun(XI, XJ)
        d2 = XI + XJ;
    end

end