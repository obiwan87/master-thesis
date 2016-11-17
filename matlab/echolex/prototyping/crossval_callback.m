function [ accuracy ] = crossval_callback(xtr, ytr, xte, yte )
%CROSSVAL_CALLBACK Summary of this function goes here
%   Detailed explanation goes here

svmmodel = fitcsvm(xtr, ytr);
predicted_labels = predict(svmmodel, xte);

accuracy = sum(predicted_labels == yte)/numel(yte);

end

