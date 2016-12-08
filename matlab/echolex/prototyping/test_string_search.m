
fprintf('strcmp() \n');
tic
Vi1 = cellfun(@(x) find(strcmp(x,terms)), D.V);
toc

fprintf('Hashes \n');
tic
Vi2 = arrayfun(@(x) find(x==terms_hash), V_hash);
toc

all(Vi1==Vi2)