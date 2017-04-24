% % % datasets = 1:7;
% % % Rs = cell(numel(datasets),1);
% % % for li=datasets
% % %     W = Ws{li};
% % %     W.tfidf();
% % %     m = W.m;
% % %     EW = W.filter_vocabulary(2,Inf,Inf);
% % %     WC = EW.wordCountMatrix();
% % %     model = fitcnb(WC, EW.Y, 'Distribution', 'mn');
% % %     d = cell2mat(model.DistributionParameters);
% % %     ig = d(1,:) - d(2,:);
% % %     ii = sorti(ig, 'descend');
% % %
% % %     F = EW.termFrequencies();
% % %     u = find(EW.Vi~=0);
% % %     F = F(u,:);
% % %     ref = EW.m.X(EW.Vi(u,:),:);
% % %     N = size(ref,1);
% % %     dist = squareform(pdist(ref, 'cosine'));
% % %     ig = ig(u);
% % %     R = zeros(N*(N-1)/2, 7);
% % %     k = 1;
% % %     for i=1:N-1
% % %         for j=(i+1):N
% % %             R(k,:) = [u(i) u(j) ig(i) ig(j) dist(i,j) F.Frequency(i) F.Frequency(j)];
% % %             k = k + 1;
% % %         end
% % %     end
% % %     Rs{li} = R;
% % %     clear R
% % % end
% %

datasets = 1:7;
dss = cell(numel(datasets),1);
fss = cell(numel(datasets),1);
llss = cell(numel(datasets),1);

distanceBinEdges = [0.0 0.3 0.4:0.1:1];

for li=1:numel(datasets)
    dataset = datasets(li);
    fprintf('Dataset %d: %d/%d \n', dataset, li,numel(datasets));
    W = Ws{dataset};
    W.tfidf();
    EW = W.filter_vocabulary(2,Inf,Inf);
    EW.tfidf();
    EW = EW.exclude_word_ids(find(EW.Vi==0));
    EW.tfidf();
    
    minF = 10;
    maxF = Inf;
    
    F = EW.termFrequencies();
    Fref = F;
    u = Fref.Frequency>=minF & Fref.Frequency<=maxF;
    uVi = EW.Vi(u);
    Fref = Fref(u,:);
    p = Fref.PDocs./(Fref.PDocs+Fref.NDocs);
    
    
    dist = pdist2(m.X(uVi, :), m.X(EW.Vi,:), 'cosine');
    dist(dist>1) = 1; % Sometimes we have distances > 1
    
    [dist_sorted, ii] = sort(dist, 2);
    
    % Put distances in 20 bins
    Y = discretize(dist_sorted, distanceBinEdges);
    
    refs = 1:size(Fref,1);
    
    deltaK = 10;
    lls = nan(numel(refs),numel(distanceBinEdges));
    fs = nan(numel(refs), numel(distanceBinEdges));
    ds = nan(numel(refs), numel(distanceBinEdges));
    
    for ref=refs
        p_ref = p(ref);
        n_ref = Fref.NDocs(ref) + Fref.PDocs(ref);
        k_ref = Fref.PDocs(ref);
        L_ref = p_ref.^k_ref*(1-p_ref).^(n_ref-k_ref);
        counts = zeros(1,numel(distanceBinEdges));
        % Get all samples sorted by size
        l = nan(size(dist,2)-1,numel(distanceBinEdges));
        f = nan(size(dist,2)-1,numel(distanceBinEdges));
        d = nan(size(dist,2)-1,numel(distanceBinEdges));
        
        for i = 2:size(dist,2)
            s = ii(ref,i);            
            y = Y(ref,i); % discretized distance (=bin number)
                        
            fs(ref,y) = fs(ref,y) + F.Frequency(s);
            ds(ref,y) = ds(ref,y) + dist(ref,s);            
            
            % Compute likelihood delta
            [deltaL, L_] = likelihood_ind(F,  n_ref, k_ref, L_ref, s); 
            
            deltaL_ = abs(1/2 - L_/(L_ref+L_));
            
            lls(ref,y) = lls(ref,y) + deltaL_;
            
            counts(y) =  counts(y) + 1;
            l(i,y) = deltaL_;
            f(i,y) = F.Frequency(s);
            d(i,y) = dist(ref,s);
        end
        fs(ref,:) = median(f, 'omitnan');
        lls(ref,:) = median(l, 'omitnan');
        ds(ref,:) = median(d, 'omitnan');
    end
   
    llss{li} = lls;
    dss{li} = ds;
    fss{li} = fs;
end
lls_all = [llss{1}; llss{2}; llss{3}; llss{4}; llss{5}; llss{6}; llss{7}];
lls_all(lls_all==Inf) = NaN;
mlls = median(lls_all,1,'omitnan');
figure; plot(distanceBinEdges, mlls);

% dss_all = [dss{1}; dss{2}; dss{3}; dss{4}; dss{5}; dss{6}; dss{7}];
% ds_s = mean(dss_all,1, 'omitnan');
% figure; plot(ds_s, mlls);
% 
% fss_all = [fss{1}; fss{2}; fss{3}; fss{4}; fss{5}; fss{6}; fss{7}];
% figure; plot(distanceBinEdges, median(fss_all,'omitnan'));


