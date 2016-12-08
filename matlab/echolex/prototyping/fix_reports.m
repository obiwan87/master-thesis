%results = store.find('{ ExperimentId: 2}','{_id: 0}');
reports = cell(size(results));
for i=1:numel(results)
    reports{i} = ExperimentReport.fromStruct(results(i));    

end

for i=1:numel(reports)
    store.add(reports{i});
end