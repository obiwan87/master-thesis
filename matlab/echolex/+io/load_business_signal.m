function [ D, labels ] = load_business_signal( name )
%LOAD_BUSINESS_SIGNAL Summary of this function goes here
%   Detailed explanation goes here

global business_signals_data

filename = fullfile(business_signals_data, sprintf('%s.txt.labels', name));
labels = dlmread(filename);
labels = categorical(labels);

filename = fullfile(business_signals_data, sprintf('%s.txt.corpus', name));
D = io.DocumentSet(filename, labels);
D.tfidf();

end

