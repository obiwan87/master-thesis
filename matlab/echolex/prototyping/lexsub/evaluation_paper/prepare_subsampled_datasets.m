runs = 5;
new_public_datasets = [];
sizes = [
    500 1000 1500 8500;
    500 1000 1500 2600;
    500 1000 1500 8500;
    500 1000 1500 8500
    ];
for i=1:numel(public_datasets_training_validation)
    d = public_datasets_training_validation{i};
    for j=1:size(sizes,1)
        for k=1:runs
            samples = randi(numel(d.Y), sizes(i,j), 1);
                        
            d1 = io.Word2VecDocumentSet(d.m, d.T(samples), d.Y(samples));
            d1.DatasetName = sprintf('%s-%d-%d', d.DatasetName, numel(samples), k)
            
            new_public_datasets{end+1} = d1;
        end
    end
end