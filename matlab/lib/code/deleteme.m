% allDocs2 = cell(size(allDocs));
% for i=1:numel(allDocs)
%     allDocs2{i} = {};
%     for j=1:numel(allDocs{i})
%         word = allDocs{i}{j};
%         if ~isempty(word)
%             allDocs2{i}{end+1} = word;
%         else
%             stop = 1;
%         end
%     end
% end


for i=1:numel(allSNum)
    fprintf('%d = %d \n', numel(allSNum{i}), numel(D.I{i}));
    
    if numel(allSNum{i}) ~= numel(D.I{i})
        stop = 1;
    end
    
    if labels(i) ~= D.Y(i)
        stop = 1;
    end
end