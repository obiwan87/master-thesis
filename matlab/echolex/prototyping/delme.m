% p = sequence(ExcludeWords('MinCount', 2, 'MaxCount', Inf), TfIdf(), SVMClassifier('CrossvalParams', {'kfold', 10}));
% h = figure; plot(pipeline(p));
% h.Position = [680   570   872   408];
% export_fig(fullfile(echolex_dumps, 'pipeline-simple-1.png'), '-r256', h);
% 
% p = sequence(fork(pgrid('ExcludeWords', 'MinCount', 2:5)), TfIdf(), SVMClassifier('CrossvalParams', {'kfold', 10}));
% h = figure; plot(pipeline(p));
% h.Position = [680   570   872   408];
% export_fig(fullfile(echolex_dumps, 'pipeline-simple-2.png'), '-r256', h);
% 
% p = sequence(fork(pgrid('ExcludeWords', 'MinCount', 2:5)), fork(TfIdf(), WordCountMatrix()), SVMClassifier('CrossvalParams', {'kfold', 10}));
% h = figure; plot(pipeline(p));
% h.Position = [680   570   872   408];
% export_fig(fullfile(echolex_dumps, 'pipeline-simple-3.png'), '-r256', h);

w = 'Eisenbahn';
sg = subgraph(d, [ W.index_of(w); nearest(d, W.index_of(w), 2, 'Method', 'unweighted')]);
sg = digraph(sg.Edges, sg.Nodes, 'OmitSelfLoops');
export_gephi_csv(sg, fullfile(echolex_dumps, 'nodes-eisenbahn.csv'), fullfile(echolex_dumps, 'eisenbahn-edges.csv'));

% h = figure; plot_terms_graph(sg);
% h.Position = [ 0 0 1920 1080];
% export_fig(fullfile(echolex_dumps, 'eisenbahn-subgraph.png'), '-r256', h);

w = 'Betrieb';
sg = subgraph(d, [ W.index_of(w); nearest(d, W.index_of(w), 2, 'Method', 'unweighted')]);
sg = digraph(sg.Edges, sg.Nodes, 'OmitSelfLoops');
% h = figure; plot_terms_graph(sg);
% h.Position = [ 0 0 1920 1080];
% export_fig(fullfile(echolex_dumps, 'eisenbahn-betrieb.png'), '-r256', h);
export_gephi_csv(sg, fullfile(echolex_dumps, 'nodes-betrieb.csv'), fullfile(echolex_dumps, 'betrieb-edges.csv'));