function [ accuracy, precision, recall ] = qualityMeasures( truths, predictions )

predictions = ~predictions;
truths = ~truths;

tp = sum(predictions & truths);
fp = sum(predictions & ~truths);
fn = sum(~predictions & truths);
precision = tp / (fp + tp);
recall = tp / (tp + fn);
accuracy = sum(predictions == truths) / numel(truths);

end

