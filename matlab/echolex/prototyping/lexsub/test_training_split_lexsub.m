
W = Ws{2};
m = W.m;
EW = W.filter_vocabulary(2,Inf,Inf);

[p,i] = min([sum(EW.Y) sum(~EW.Y)]);

accs1 = [];
accs2 = [];
accs3 = [];
accs4 = [];

runs = 1;
Ts = cell(runs,1);
STs = cell(runs,1);
entireDataModel = fitcnb(EW.wordCountMatrix(), EW.Y, 'Distribution', 'mn');
d = cell2mat(entireDataModel.DistributionParameters);
ig = d(1,:) - d(2,:);
igmap = containers.Map;

tic
for k=1:numel(EW.V)
    igmap(EW.V{k}) = ig(k);
end
toc

rng default 
for k=1:runs

c = cvpartition(EW.Y, 'holdout', 0.6);

% Test dataset
teD = io.Word2VecDocumentSet(m, EW.T(test(c)), EW.Y(test(c)));

% Training Dataset
trD = io.Word2VecDocumentSet(m, EW.T(training(c)), EW.Y(training(c)));

% Apply substitutions only from V_unseen -> V_seen
[lD, S, ST] = prob_lexsub(trD, teD, 'MinSimilarity', 0.7, 'SubstitutionThreshold', 5, 'K', 5, 'FrequencyCoefficient', 3.5);

lT = cell(numel(EW.T), 1);
lT(test(c)) = lD.T;
lT(training(c)) = trD.T;
lY = zeros(numel(EW.Y),1);
lY(test(c)) = lD.Y;
lY(training(c)) = trD.Y;

lEW = io.Word2VecDocumentSet(m, lT, lY);

% Without substitution
WC = EW.wordCountMatrix();

nbmodel = fitcnb(WC(training(c),:), EW.Y(training(c),:), 'Distribution', 'mn' );
[predictions, posterior] = predict(nbmodel, WC(test(c),:));

correctPredictions = predictions == EW.Y(test(c));
accs1(end+1) = sum(correctPredictions)/sum(test(c));

% With substitution
WC = lEW.wordCountMatrix();
nbmodel2 = fitcnb(WC(training(c),:), lEW.Y(training(c),:), 'Distribution', 'mn' );
[predictions2, posterior2] = predict(nbmodel2, WC(test(c),:));

correctPredictions2 = predictions2 == lEW.Y(test(c));

accs2(end+1) = sum(correctPredictions2)/sum(test(c));

differentPredictions = find(predictions ~= predictions2);
t = find(test(c));

origS = arrayfun(@(x) strjoin(EW.T{t(x)}, ' ')', differentPredictions, 'UniformOutput', false);
subS = arrayfun(@(x) strjoin(lEW.T{t(x)}, ' ')', differentPredictions, 'UniformOutput', false);

testIdx = find(test(c));
if ~isempty(origS)
    Ts{k} = table(testIdx(differentPredictions), ...
                  origS, ...
                  predictions(differentPredictions), ...
                  posterior(differentPredictions,:), ...
                  subS, ...
                  predictions2(differentPredictions), ...
                  posterior2(differentPredictions,:), ...
                  EW.Y(t(differentPredictions)),...
              'VariableNames', {'ID', 'NoSub','PredLabelNoSub', 'PosteriorNoSub', 'Sub', 'PredLabelSub', 'PosteriorSub', 'RealLabel'});
end

igOrig = cellfun(@(x) igmap(x), ST.OrigV);
igSubst = cellfun(@(x) igmap(x), ST.SubstV);

IG = table(igOrig, igSubst);
ST = [ST IG];
STs{k} = ST;

% Compare which sentences were misclassified/correctly classified after
% substitution

% Lexical Substitution algorithm ( substitutions on training data only)
%lexsub = ProbabilisticLexicalSubstitution('MinSimilarity', 0.75, 'SubstitutionThreshold', 10, 'MaxIter', 1, 'K', 5);
%r = lexsub.doExecute([], struct('DocumentSet', trD));

% Training data: features reduced by lexical substitution
%     ltrD = r.Out;
%
%     lT(test(c)) = lD.T;
%     lT(training(c)) = ltrD.T;
%     lY = zeros(numel(EW.Y),1);
%     lY(test(c)) = lD.Y;
%     lY(training(c)) = ltrD.Y;
%
%     lEW = io.Word2VecDocumentSet(m, lT, lY);
%     WC = lEW.wordCountMatrix();
%     nbmodel = fitcnb(WC, lEW.Y, 'CVPartition', c, 'Distribution', 'mn' );
%     accs3 = [accs3; 1 - kfoldLoss(nbmodel, 'mode', 'average')];
%
%     [lD, S] = prob_lexsub(ltrD, teD, 'MinSimilarity', 0.5, 'SubstitutionThreshold', 4, 'MaxIter', 1, 'K', 5);
%
%     lT(test(c)) = lD.T;
%     lT(training(c)) = ltrD.T;
%     lY = zeros(numel(EW.Y),1);
%     lY(test(c)) = lD.Y;
%     lY(training(c)) = ltrD.Y;
%
%     lEW = io.Word2VecDocumentSet(m, lT, lY);
%     WC = lEW.wordCountMatrix();
%     nbmodel = fitcnb(WC, lEW.Y, 'CVPartition', c, 'Distribution', 'mn' );
%     accs4 = [accs4; 1 - kfoldLoss(nbmodel, 'mode', 'average')];
end