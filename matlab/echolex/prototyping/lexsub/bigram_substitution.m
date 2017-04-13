bEW = bW;

bigrams = bEW.V;
B = cellfun(@(x) contains(x, '_'), bigrams);
bigrams = bigrams(B);

bigrams = cellfun(@(x) strsplit(x, '_'), bigrams, 'UniformOutput', false);
B = cellfun(@(x) numel(x) == 2, bigrams);
bigrams = bigrams(B);

% All different unigrams
unigrams = union(cellfun(@(x) x{1}, bigrams, 'UniformOutput', false), cellfun(@(x) x{2}, bigrams, 'UniformOutput', false));

% Mappings to word2vec vocabulary
vi  = zeros(numel(unigrams), 1);
[~,ia,ib] = intersect(unigrams, m.Terms);
vi(ia) = ib;

% Create map from word to word2vec index
vimap = containers.Map;
for li=1:numel(vi)
    vimap(unigrams{li}) = vi(li);
end

% Establish which unigram of the bigram is available in word2vec vocabulary
inw2v = zeros(numel(bigrams),2);
for li=1:numel(bigrams)
    inw2v(li,:) = [vimap(bigrams{li}{1})>0 vimap(bigrams{li}{2})>0];
end

% Select only bigrams whose unigrams are both in word2vec vocabulary
inw2v_bigrams = bigrams(sum(inw2v,2) == 2);
w2vvi = find(vi~=0);

inw2v_unigrams = unigrams(w2vvi);

k = 1;
N_b = numel(inw2v_bigrams);
% 
% % Apprach 1: Stack vectors
% % X = zeros(numel(inw2v_bigrams), 2*size(m.X,2));
% % bigrams_readable = cell(numel(bigrams),1);
% % for li=1:N_b
% %     % Bigram
% %     b1 = inw2v_bigrams{li};
% %     
% %     % Unigrams of Bigram
% %     w1 = b1{1};
% %     w2 = b1{2};
% %     
% %     bigrams_readable{li} = strcat(w1,'_',w2);
% %     
% %     % Find indices in query set of pdist
% %     i1 = vimap(w1);
% %     
% %     i2 = vimap(w2);
% %     
% %     % Stack vectors
% %     X(li,:) = [m.X(i1,:) m.X(i2,:)];
% % end
% 
% %K = 5;
% %[bnns, bdist] = knnsearch(X,X, 'k', 5, 'distance', 'cosine');
bEW = bW;

bigrams = bEW.V;
B = cellfun(@(x) contains(x, '_'), bigrams);
bigrams = bigrams(B);

bigrams = cellfun(@(x) strsplit(x, '_'), bigrams, 'UniformOutput', false);
B = cellfun(@(x) numel(x) == 2, bigrams);
bigrams = bigrams(B);

% All different unigrams
unigrams = union(cellfun(@(x) x{1}, bigrams, 'UniformOutput', false), cellfun(@(x) x{2}, bigrams, 'UniformOutput', false));

% Mappings to word2vec vocabulary
vi  = zeros(numel(unigrams), 1);
[~,ia,ib] = intersect(unigrams, m.Terms);
vi(ia) = ib;

% Create map from word to word2vec index
vimap = containers.Map;
for li=1:numel(vi)
    vimap(unigrams{li}) = vi(li);
end

% Establish which unigram of the bigram is available in word2vec vocabulary
inw2v = zeros(numel(bigrams),2);
for li=1:numel(bigrams)
    inw2v(li,:) = [vimap(bigrams{li}{1})>0 vimap(bigrams{li}{2})>0];
end

% Select only bigrams whose unigrams are both in word2vec vocabulary
inw2v_bigrams = bigrams(sum(inw2v,2) == 2);
w2vvi = find(vi~=0);

inw2v_unigrams = unigrams(w2vvi);

k = 1;
N_b = numel(inw2v_bigrams);

% All unigrams that appear in first position
unigrams1 = unique(cellfun(@(x) x{1}, inw2v_bigrams, 'UniformOutput', false));

% All unigrams that appear in second position
unigrams2 = unique(cellfun(@(x) x{2}, inw2v_bigrams, 'UniformOutput', false));

w2v_u1_vi = cellfun(@(x) vimap(x), unigrams1);
w2v_u2_vi = cellfun(@(x) vimap(x), unigrams2);

assert(sum(w2v_u1_vi==0) == 0);
assert(sum(w2v_u2_vi==0) == 0);

distu1 = squareform(pdist(m.X(w2v_u1_vi,:), 'cosine'));
distu2 = squareform(pdist(m.X(w2v_u2_vi,:), 'cosine'));

u1vimap = containers.Map;
for li=1:numel(unigrams1)
    u1vimap(unigrams1{li}) = li;
end

u2vimap = containers.Map;
for li=1:numel(unigrams2)
    u2vimap(unigrams2{li}) = li;
end

% Approach 2: Average distances
theta_d = 0.55;
bigrams_readable = cell(numel(inw2v_bigrams),1); 
bigram_indices = zeros(numel(inw2v_bigrams),2);
for li=1:N_b-1
    b1 = inw2v_bigrams{li};
    
    % Unigrams of Bigram
    w1 = b1{1};
    w2 = b1{2};
    
    % Find indices in query set of pdist
    i1 = u1vimap(w1);
    i2 = u2vimap(w2);
    
    bigram_indices(li,1:2) = [i1 i2];
    bigrams_readable{li} = [w1 '_' w2];
end

bnns2 = cell(size(bigram_indices,1),1);
bnns2readable = cell(size(bigram_indices,1),1);
bdist2 = cell(size(bigram_indices,1),1);

for li=1:N_b-1
   u1 = bigram_indices(li,1);
   u2 = bigram_indices(li,2);
   
   % Find unigrams with distance < theta_d       
   d1 = find(distu1(u1,:)<theta_d);
   bs = false(N_b,1);
   
   for i=1:numel(d1)
       bs = bs | (bigram_indices(:,1) == d1(i));
   end
   
   bsi = setdiff(find(bs), li);
      
   % find second unigrams contained in bigrams bs
   u2s = unique(bigram_indices(bsi,2));
   d2 = find(distu2(u2, u2s) < theta_d);
   
   bs1 = bs;
   bs = false(N_b,1);
   
   for i=1:numel(d2)
       bs = bs | (bigram_indices(:,2) == u2s(d2(i)));
   end
   
   bs = find(bs1 & bs);

   dist_u1u2 = [distu1(u1,bigram_indices(bs,1)); distu2(u2,bigram_indices(bs,2))];
   sim_u1u2 = min(1-dist_u1u2,[],1);
   ii = sorti(sim_u1u2, 'descend');
   
   bnns2{li} = bs(ii);
   bdist2{li} = sim_u1u2(ii);
   bnns2readable{li} = table(bigrams_readable(bs(ii)), sim_u1u2(ii)');
end

% Find bigrams whose first unigram is not in word2vec vocabulary
% We can only find candidates whose first unigram is lexically identical

% For second unigram just switch columns of inw2v and bigrams_outw2v and re-use this code
firstUnigramMatch = inw2v(:,1) == 1 & inw2v(:,2) == 0;
bigrams_outw2v = bigrams(firstUnigramMatch);

unigrams1 = unique(cellfun(@(x) x{1}, bigrams_outw2v, 'UniformOutput', false));
unigrams2 = unique(cellfun(@(x) x{2}, bigrams_outw2v, 'UniformOutput', false));

u1vimap = containers.Map;
u2vimap = containers.Map;

for li=1:numel(unigrams1)
    u1vimap(unigrams1{li}) = li;
end

for li=1:numel(unigrams2)
    u2vimap(unigrams2{li}) = li;
end

bigram_indices = zeros(numel(bigrams_outw2v), 2);
bigrams_readable = cell(numel(bigrams_outw2v),1);
for li=1:size(bigram_indices,1)
    b = bigrams_outw2v{li};
    
    w1 = b{1};
    w2 = b{2};
    
    bigram_indices(li,1) = u1vimap(w1);
    bigram_indices(li,2) = u2vimap(w2);
    bigrams_readable{li} = [w1 '_' w2];
end

w2v_u1_v1 = cellfun(@(x) vimap(x), unigrams1);
distu1 = squareform(pdist(m.X(w2v_u1_v1,:), 'cosine'));
theta_d = 0.55;
bnns2readable = cell(size(bigram_indices,1),1);
for li=1:numel(bigrams_outw2v)
    u1 = bigram_indices(li,1);
    u2 = bigram_indices(li,2);
    
    bs = find(bigram_indices(:,2) == u2);
            
    bs1 = find(distu1(u1,bigram_indices(bs,1)) < theta_d);
    d1 = distu1(u1,bigram_indices(bs(bs1),1));
    sim_u1 = 1 - d1;
    ii = sorti(sim_u1, 'descend');
    bnns2readable{li} = table(bigrams_readable(bs(bs1(ii))), sim_u1(ii)');
end

secondUnigramMatch = inw2v(:,2) == 1 & inw2v(:,1) == 0;
