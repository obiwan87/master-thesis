function [e, posterior, accuracy] = modelQuality(model, data, labels, c )

testSet = find(test(c));

[predictions, posterior] = predict(model, data(testSet,:));

accuracy = sum(predictions == labels(testSet))/numel(testSet);
ipos = sub2ind(size(posterior), 1:size(posterior,1), double(labels(test(c)))' + 1);

p = posterior(ipos);
e = 1 - p;

end

