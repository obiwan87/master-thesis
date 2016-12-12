groups = unique(substitutes(:,2));

for i=1:numel(groups)
   w = find(substitutes(:,2) == groups(i));
   if numel(w) > 1
        W.V(w)
   end
end