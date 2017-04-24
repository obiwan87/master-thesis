lexsub = GACLexicalSubstitution('K', 20, 'GroupNumber', 1220);
LW = lexsub.doExecute([], struct('Word2VecDocumentSet', Ws2{1}));
% 
% 
clusters = LW.clusteredLabels;

W = Ws2{1};
nZ = find(W.Vi ~= 0);

C = unique(clusters);

f = fopen(fullfile(echolex_dumps, 'clusters-20nn.txt'), 'w+');
for i=1:numel(C)
    samples = nZ(C(i) == clusters);
    fprintf(f, '\nCluster %d \n ------------------- \n', i);    
    fprintf(f, '%s\n', W.V{samples});
end