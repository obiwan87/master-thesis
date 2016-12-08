groups = unique(clusteredLabels);


for i=1:numel(groups)
   w = find(clusteredLabels == groups(i));
   Wke.V(w)
end