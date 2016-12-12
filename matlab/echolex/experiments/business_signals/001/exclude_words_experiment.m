% Experiment: Asses classification performance after leaving out
% non-frequent words to rule out overfitting due to specicif words.
% Ds = cellfun(@(x) io.load_business_signal(x), business_signals, 'UniformOutput', false);
% Ws = cellfun(@(D) io.Word2VecDocumentSet(m,D.T,D.Y), Ds, 'UniformOutput', false);
% func.apply(Ws, @(W) W.tfidf())

experiment_id = 1;
name = 'Exclude Words';
description = 'Rule out overfitting';

S = {'ExcludeWords', {'vocBefore', 'info.vocSizeBefore', 'vocAfter', 'info.vocSizeAfter'}};

scheme = ReportScheme(S{:});
for i=1:numel(Ws)         
    dataset = business_signals{i};    
    
    W = Ws{i};
    
    R = ExperimentReport(experiment_id, dataset, name, description, scheme);   
    p = {};
    
    % Create combinations of exclude words 
    g = grid('ExcludeWords', 'MinCount', 1:5, 'MaxCount', Inf);
    
    p{end+1} = fork(g); %#ok<*SAGROW>
    p{end+1} = TfIdf();
    p{end+1} = SVMClassifier('CrossvalParams', {'KFold', 30});
    P = pipeline(p);
    
    disp(dataset);
    % input, reporter
    P.execute(W, R);
    store.add(R);
end

plot(R);
