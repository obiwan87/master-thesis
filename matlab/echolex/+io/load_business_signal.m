function [ D, labels ] = load_business_signal( name )
%LOAD_BUSINESS_SIGNAL Summary of this function goes here
%   Detailed explanation goes here

global business_signals_data

D = io.DocumentSet(fullfile(business_signals_data, sprintf('%s.txt.corpus', name)));
D.tfidf();

labels = dlmread(fullfile(business_signals_data, sprintf('%s.txt.labels', name)));
labels = categorical(labels);
labels(D.EmptyLines) = [];

end

