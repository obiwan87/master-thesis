function [ bnns, bdist ] = bigrams_pdist2( m, bigrams_ref, bigrams_query, varargin )
% BIGRAMS_PDIST2 Summary of this function goes here
%   Detailed explanation goes here

% * Get bigrams of test dataset (query) and training dataset (ref)
% * Refine bigrams of test to those only occuring less than theta_f times in
%   ref
% ------------------ BOTH UNIGRAMS IN WORD2VEC VOCABULARY ----------------
% * Calculate unigrams of bigrams of query and ref
% * Get neighbors of i-th unigrams within radius theta_d
% * Calculate an overall distance between unigrams
%       o d = f(d1,d2) e.g.
%           - f(d1,d2) = harmmean(d1,d2)
%           - f(d1,d2) = min(d1,d2) ...
%
% ------------------ ONE UNIGRAM IN WORD2VEC VOCABULARY ------------------
% * Only look for candidates among bigrams whose unigram that is not in the word2vec
%   vocabulary is identical to the reference bigram
p = create_parser();
parse(p,varargin{:});

params = p.Results;

theta_d = params.MaxDistance;
f = params.DistanceMergeFunction; % Merges distances from d(u1,u1') and d(u2,u2')

bigrams_ref = fetch_bigrams(bigrams_ref);
bigrams_query = fetch_bigrams(bigrams_query);

[unigrams1_query, unigrams2_query, bigrams_i_query] = fetch_unigrams_of_bigrams(bigrams_query);
[unigrams1_ref, unigrams2_ref, bigrams_i_ref] = fetch_unigrams_of_bigrams(bigrams_ref);

[bigrams_w2v_i_query, unigrams1_w2v_i_query, unigrams2_w2v_i_query] = bigrams_w2v_index(m, bigrams_query, bigrams_i_query);
[bigrams_w2v_i_ref, unigrams1_w2v_i_ref, unigrams2_w2v_i_ref] = bigrams_w2v_index(m, bigrams_ref, bigrams_i_ref);

% TEST SET INDEXES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nZ_u1_w2v_i_query = unigrams1_w2v_i_query(unigrams1_w2v_i_query~=0);
i2Nz_u1_query = zeros(numel(unigrams1_query),1);
i2Nz_u1_query(unigrams1_w2v_i_query~=0) = 1:sum(unigrams1_w2v_i_query~=0);
nZ2i_u1_query = find(unigrams1_w2v_i_query~=0);

nZ_u2_w2v_i_query = unigrams2_w2v_i_query(unigrams2_w2v_i_query~=0);
i2Nz_u2_query = zeros(numel(unigrams2_query),1);
i2Nz_u2_query(unigrams2_w2v_i_query~=0) = 1:sum(unigrams2_w2v_i_query~=0);
nZ2i_u2_query = find(unigrams2_w2v_i_query~=0);

% TRAINING SET INDEXES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nZ_u1_w2v_i_ref = unigrams1_w2v_i_ref(unigrams1_w2v_i_ref~=0);
i2Nz_u1_ref = zeros(numel(unigrams1_ref),1);
i2Nz_u1_ref(unigrams1_w2v_i_ref~=0) = 1:sum(unigrams1_w2v_i_ref~=0);
nZ2i_u1_ref = find(unigrams1_w2v_i_ref~=0);

nZ_u2_w2v_i_ref = unigrams2_w2v_i_ref(unigrams2_w2v_i_ref~=0);
i2Nz_u2_ref = zeros(numel(unigrams2_ref),1);
i2Nz_u2_ref(unigrams2_w2v_i_ref~=0) = 1:sum(unigrams2_w2v_i_ref~=0);
nZ2i_u2_ref = find(unigrams2_w2v_i_ref~=0);

%% Distance-Threshold based method


dist_u1 = pdist2(m.X(nZ_u1_w2v_i_query,:), m.X(nZ_u1_w2v_i_ref,:), 'cosine');
dist_u2 = pdist2(m.X(nZ_u2_w2v_i_query,:), m.X(nZ_u2_w2v_i_ref,:), 'cosine');

bdist = cell(size(bigrams_query,1), 1);
bnns  = cell(size(bigrams_query,1), 1);

for i=1:size(bigrams_query,1)
    
    b = bigrams_query(i,:); % Bigram String
    b_i = bigrams_i_query(i,:); % Bigram index within corpus
    bw2v = bigrams_w2v_i_query(i,:); % Bigram index withing w2v
    
    w2v_u1_i_query = bw2v(1);
    w2v_u2_i_query = bw2v(2);
    
    if w2v_u1_i_query ~= 0 && w2v_u2_i_query ~= 0
        u1_i = i2Nz_u1_query(b_i(1));
        
        u1_c = dist_u1(u1_i,:) <= theta_d;
        u1_c_i = nZ2i_u1_ref(u1_c);
        
        % Query bigrams whose unigrams are in u1_c_i
        u1_query = false(size(bigrams_ref,1),1);
        for j=1:numel(u1_c_i)
            lj = u1_c_i(j);
            u1_query = u1_query | lj == bigrams_i_ref(:,1);
        end
        
        % Take all candidates whose second bigram is also in w2v
        u1_query = u1_query & bigrams_w2v_i_ref(:,2) ~= 0; 
        queried_u2_ref = unique(bigrams_i_ref(u1_query,2));
        
        % Calculate distance to second unigrams of queried bigrams
        
        u2 = unigrams2_w2v_i_ref(queried_u2_ref);
        u2 = queried_u2_ref(u2~=0);
        [~,~,u2_i_ref] = intersect(u2, nZ2i_u2_ref);
        
        u2_i = nZ2i_u2_query == b_i(2);
        
        u2_c = find(dist_u2(u2_i,u2_i_ref) < theta_d);
        u2_query = false(size(bigrams_ref,1),1);
        
        for j=1:numel(u2_c)
            lj = nZ2i_u2_ref(u2_i_ref(u2_c(j)));
            u2_query = u2_query | lj == bigrams_i_ref(:,2);
        end
        
        b_query = find(u1_query & u2_query);
        dists1 = dist_u1(u1_i, i2Nz_u1_ref(bigrams_i_ref(b_query,1)));
        dists2 = dist_u2(u2_i, i2Nz_u2_ref(bigrams_i_ref(b_query,2)));
        d = [dists1; dists2];
        
        if ~isempty(d)
            d = f(d);
        end
        
        ii = sorti(d);
        bdist{i} = d(ii);
        bnns{i} = b_query(ii);
        
    elseif w2v_u1_i_query > 0 || w2v_u2_i_query > 0        
        li = find([w2v_u1_i_query > 0 w2v_u2_i_query > 0]);        
        lo = mod(li,2)+1;
        uo_query = strcmp(b{lo}, bigrams_ref(:,lo));
        queried_u_ref = unique(bigrams_i_ref(uo_query,li)); %#ok<NASGU>
        eval(sprintf('u_ref = i2Nz_u%d_ref(queried_u_ref);',li));
        u_ref = u_ref(u_ref~=0);
        
        eval(sprintf('u_i = i2Nz_u%d_query(b_i(%d));', li,li));
        eval(sprintf('dists = dist_u%d(u_i,u_ref);',li));
        u_c = find(dists < theta_d);
        
        ui_query = false(size(bigrams_ref,1),1);
        for j=1:numel(u_c)
            eval(sprintf('lj = nZ2i_u%d_ref(u_ref(u_c(j)));', li));
            ui_query = ui_query | lj == bigrams_i_ref(:,li);
        end
        
        b_query = find(uo_query & ui_query);
                
        distso = zeros(1,numel(b_query));
        distsi = dists(u_c);
        d = [distso; distsi];
        
        if ~isempty(d)
            d = f(d);
        end
        
        ii = sorti(d);
        bdist{i} = d(ii);
        bnns{i} = b_query(ii);        
    end
end

end

function [bigrams, B] = fetch_bigrams(bigrams)

bigrams = cellstr(string(bigrams).split('_'));

end

function [unigrams1, unigrams2, bigrams_i] = fetch_unigrams_of_bigrams(bigrams)

[unigrams1, ~, u1_i] = unique(bigrams(:,1));
[unigrams2, ~, u2_i] = unique(bigrams(:,2));

bigrams_i = [u1_i u2_i];
end

function [bigrams_w2v_i, unigrams1_w2v_i, unigrams2_w2v_i] = bigrams_w2v_index(m, bigrams, bigrams_i)
unigrams1 = unique(bigrams(:,1));
unigrams2 = unique(bigrams(:,2));

unigrams1_w2v_i = zeros(size(unigrams1));
[~, ia, u1_w2v_i] = intersect(unigrams1, m.Terms);
unigrams1_w2v_i(ia) = u1_w2v_i;

unigrams2_w2v_i = zeros(size(unigrams2));
[~, ia, u2_w2v_i] = intersect(unigrams2, m.Terms);
unigrams2_w2v_i(ia) = u2_w2v_i;

bigrams_w2v_i = zeros(size(bigrams_i));
bigrams_w2v_i(:,1) = unigrams1_w2v_i(bigrams_i(:,1));
bigrams_w2v_i(:,2) = unigrams2_w2v_i(bigrams_i(:,2));
end

function p = create_parser()
p = inputParser;
p.KeepUnmatched = true;

% Algorithm Parameters
addParameter(p, 'MaxDistance', 0.55, @(x) x > 0);
addParameter(p, 'DistanceMergeFunction', @(X) max(X,[],1), @(x) isa(x, 'function_handle'));

end