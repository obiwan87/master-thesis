function [ngrams] = fetch_ngrams(ngrams)

ngrams = cellstr(string(ngrams).split('_'));

end
