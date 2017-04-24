% Learn substitutions with regression

W = Ws{2};

W = W.filter_vocabulary(2,Inf,Inf);
ref = W.m.X(W.Vi(W.Vi~=0,:),:);
[nns, dist] = knnsearch(ref, ref, 'K', size(ref,1), 'distance', 'cosine');

V = W.V(W.Vi~=0);
F = W.termFrequencies();
F = F.Frequency(W.Vi ~= 0);
rng default 
c = cvpartition(W.Y, 'holdout', 0.5);

WC = W.wordCountMatrix();
WC = WC(:,W.Vi~=0);

trWC = WC(training(c),:);
trF = sum(trWC);

model = fitcnb(trWC, W.Y(training(c)), 'Distribution', 'mn');
e = modelQuality(model, WC, W.Y, c);
baseError = mean(e);

N = 10000;

K = 5;
nZ = find(sum(trWC) > 0);
trF = trF(nZ);
nnsNZ = nns(nZ,nZ);
distNZ = dist(nZ,nZ);
weights = distNZ(:,1:K);
sample = randi(numel(weights), N, 1);
[row, col] = ind2sub(size(weights), sample);
sample = [row col]';
R = zeros(N,4);

dp = cell2mat(model.DistributionParameters);
ig = abs(diff(dp,2));
sample = sample(:,sample(2,:) ~= 1);

for i=1:size(sample,2)    
    fprintf('%d/%d \n', i, size(sample,2));
    w1 = sample(1,i);
    w2 = sample(2,i);
    
    f1 = trF(w1);
    f2 = trF(w2);
    ig1 = ig(w1);
    ig2 = ig(w2);
    d = double(distNZ(w1,w2));
    
    sWC = WC;
    sWC(test(c),nZ(w1)) = sWC(test(c),nZ(w1)) + sWC(test(c),nZ(w2));
    sWC(test(c),nZ(w2)) = 0;
    
    e = modelQuality(model, sWC, W.Y, c);
    newError = mean(e);
    
    R(i,:) = [f1 f2  d baseError - newError];
end
