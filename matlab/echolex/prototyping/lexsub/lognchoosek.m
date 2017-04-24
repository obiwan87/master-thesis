function l = lognchoosek(n,k)
    ln = log(n);
    lk = log(k);
    lnk = log(n-k);
    % Stirling approximation
    l = n*ln - k*lk - (n - k)*lnk + 0.5*(ln - lk - lnk- log(2*pi));
end