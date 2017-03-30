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
    refs= 1:size(Fref,1);
    
    K = 5:5:113;
    
    %distanceBins = 0:0.05:1;
    
    deltaK = 10;
    lls = zeros(numel(refs),numel(K));
    fs = zeros(numel(refs), numel(K));
    ds = zeros(numel(refs), numel(K));
    
    for ref=refs
        p_ref = p(ref);
        n_ref = Fref.NDocs(ref) + Fref.PDocs(ref);
        k_ref = Fref.PDocs(ref);
        L_ref = p_ref.^k_ref*(1-p_ref).^(n_ref-k_ref);
        
        sample_size = 3;
        for i = 1:numel(K)
            
            ii = sorti(dist(ref,:),'ascend');
            c = ii(2:(K(i)+1));
            
            for k=1:1000
                s = randsample(c,sample_size);
                
                fs(ref,i) = fs(ref,i) + sum(F.Frequency(s));
                ds(ref,i) = ds(ref,i) + sum(dist(ref,c));
                assert(~isempty(c));
                
                %lls(ref,i) = lls(ref,i) + likelihood_(F, p_ref,s,p(s));
                
                lls(ref,i) = lls(ref,i) + likelihood_ind(F,  n_ref, k_ref, L_ref, s);
            end
            fs(ref,i) =  1/k * fs(ref,i);
            ds(ref,i) =  1/(k*K(i)) * ds(ref,i);
            lls(ref,i) = 1/k * lls(ref,i);
            
        end
    end
    
    llss{li} = lls;
    dss{li} = ds;
    fss{li} = fs;
end
lls_all(lls_all==Inf) = NaN;
mlls = mean(lls_all,1,'omitnan');
figure; plot(K, mlls);

[ds_s, ii] = sort(mean(dss_all,1),'ascend');
figure; scatter(ds_s, mlls(ii), '.');

figure; scatter(K, mean(fss_all,1));


