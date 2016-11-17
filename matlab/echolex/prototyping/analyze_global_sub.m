% Analyze which words have been subsituted by global knn substitution
LV = unique(LVi);
S = histc(LVi, LV);

[~, ii] = sort(S, 'descend');

GS = cell(max(S)+1,numel(S));
for i=1:numel(S)
    k = LV(ii(i));
    fprintf('Substitutes for ''%s'' \n', terms{k});
    s = find(LVi == k);
    GS{1,i} = terms{k};
    GS(2:S(ii(i))+1,i) = D.V(s);   
end

writetable(cell2table(GS'), 'substitutions.dat');

i = D.index_of('CEO'); % Analyzed word

idx = gnns(i,:);

fprintf('Canditates for ''%s'' \n', D.V{i});
I = arrayfun(@(x) find(x==N),idx,'UniformOutput', true);

% Find out which of the candidates are already in our Text Corpus
inF = D.termFrequencies();
in_corpus = 

weights = arrayfun(@(x) mean(dist(gnns==x)), gnns(i,:), 'UniformOutput', true);
% Calculate PCA    
nX = X(gnns(i,:),:);
[coeff, ~, ~, ~, explained] = pca(nX);

dims = 2;
pcaX = double(nX*coeff(:,1:dims));
pcaDist = pdist2(pcaX(1,:), pcaX(1:end,:),'euclidean');
epsilon = 0.5;
%F(I)./(dist(i,:).^3)', F(I)./(dist(i,:).^2)', F(I)./(dist(i,:))'
realF = F(I) + in_corpus';
FT= table(terms(gnns(i,:)),F(I),realF,dist(i,:)',pcaDist', F(I)./(pcaDist' + epsilon), (realF ./ dist(i,:)').*weights');