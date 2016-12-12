query = fileread('006_query.js');
results = store.aggregate(query);
h = figure;


for i=1:numel(results)
    subplot(1,3,i);
    hold on
    holdout = results(i).holdout;
    for j=1:numel(results(i).preprocessor)
        loss = results(i).loss(j,:);
        plot(holdout, loss);
        xlabel('Holdout');
        ylabel('Loss');
        dataset = results(i).dataset;
        dataset(1) = upper(dataset(1));
        title(dataset);        
    end
    legend(results(i).preprocessor);
end