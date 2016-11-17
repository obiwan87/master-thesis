clear nns; 
local_knn_lexical_substitution

ks = 200:-20:20;
glosses = zeros(numel(ks),2);
for kk=1:numel(ks)
    if kk==1
        clear gnns
    else 
        gnns = gnns(:,1:ks(kk));
    end
    
    K = ks(kk)
    tic
    global_knn_lexical_substitution
    toc
    glosses(kk,1) = numel(unique(LVi));
    glosses(kk,2) = loss;
end

figure;
losses = losses(end:-1:1,:);
plot(losses(:,1), losses(:,2));
ax = gca;
hold on
glosses = glosses(end:-1:1,:);
plot(glosses(:,1), glosses(:,2));

legend({'Iterative Local Lexical Substitution', 'Global Substitution'});