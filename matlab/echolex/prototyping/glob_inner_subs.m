fid = fopen('substitutions-graph-3.txt', 'w+');
innerLVi = innerCorpusSubstitutions;
for i=1:numel(innerLVi)
    idx = innerLVi(i);
    if idx == -1
        continue
    end
    
    fprintf(fid, '%s -> %s ', D.V{i}, D.V{idx});
    nidx = idx;
    prev_nidx = NaN;
    while nidx ~= prev_nidx && nidx ~= -1
        prev_nidx = nidx;
        nidx = innerLVi(nidx);
        if nidx ~= -1
            fprintf(fid, '-> %s ', D.V{nidx});
        end        
    end
    innerLVi(idx) = nidx;
    fprintf(fid, '\n');
end
innerLVi(innerLVi ~= -1) = arrayfun(@(x) find(strcmp(D.V{x},terms)), innerLVi(innerLVi ~= -1));
innerLVi(innerLVi ==-1 ) = LVi(innerLVi == -1);
LI = cellfun(@(s) innerLVi(s), D.I, 'UniformOutput', false);
LT = cellfun(@(s) terms(s)', LI, 'UniformOutput', false);