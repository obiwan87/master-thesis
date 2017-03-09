function [ D, labels ] = load_business_signal( name, bigrams )
%LOAD_BUSINESS_SIGNAL Summary of this function goes here
%   Detailed explanation goes here

if nargin < 2
    bigrams = false;
end

global business_signals_data

filename = fullfile(business_signals_data, sprintf('%s.txt.labels', name));
labels = uint8(dlmread(filename));

if iscolumn(labels) % just for prettier json representation
    labels = labels';
end
% labels = categorical(labels);

if ~bigrams
    filename = fullfile(business_signals_data, sprintf('%s.txt.corpus', name));
else
    filename = fullfile(business_signals_data, sprintf('%s.txt.corpus.bigrams', name));
end
D = io.DocumentSet(filename, labels);
D.tfidf();

end

