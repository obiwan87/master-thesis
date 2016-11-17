rng default

for s=randperm(numel(D.T), 10)
S = D.I{s};

nS = cell(size(D.T{s}));
nI = zeros(size(S));
wDist = zeros(size(S));
for k=1:numel(S)
    i = S(k);
    idx = gnns(i,:);
    if mod(i,100)==0
        fprintf('%d / %d \n', i, numel(Ss));
    end
    
    I = arrayfun(@(x) find(x==N),idx,'UniformOutput', true);
    realF = arrayfun(@(x) emptyas(inF.Frequency(strcmp(terms{x}, D.V))), idx, 'UniformOutput', true);
    realF = (F(I) + realF')./(exp(1.3*dist(i,:)'));
    [~,j] = max(realF(1:end));
    
    nI(k) = gnns(i,j);
    wDist(k) = dist(i, j);
    nS{k} = terms{nI(k)};
end

%fprintf(strcat(func.foldr(D.T{s}, [], @(x,y) [x ' ' y]), '\n'));
%fprintf(strcat(func.foldr(nS, [], @(x,y) [x ' ' y]), '\n'));
cell2table([D.T{s}; nS; num2cell(wDist)])
fprintf('-------------------------\n\n');
end