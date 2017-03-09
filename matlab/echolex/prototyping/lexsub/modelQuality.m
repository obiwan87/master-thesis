function [e, posterior, accuracy, model] = modelQuality( data, labels, c )

trainingSet = training(c);
testSet = find(test(c));

model = fitcnb(data(trainingSet,:), labels(trainingSet), 'Distribution', 'mn');
[predictions, posterior] = predict(model, data(testSet,:));

accuracy = sum(predictions == labels(testSet))/numel(testSet);
ipos = sub2ind(size(posterior), 1:size(posterior,1), double(labels(test(c)))' + 1);

p = posterior(ipos);
e = 1 - p;

end

