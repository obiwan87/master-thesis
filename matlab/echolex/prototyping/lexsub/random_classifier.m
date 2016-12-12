repeats = 100;
for i=1:numel(Ws)

classes = unique(W.Y);    
accuracies = zeros(repeats, 1);
for k=1:repeats
    predictions = classes(randi(numel(classes), numel(W.Y),1));
    accuracies(k) = sum(predictions == W.Y)/numel(W.Y);
end
mean(accuracies)
end