plot_dir = 'D:\projects\lexical-substitution\learning-samples-lexical\figures';
classifiers = {'MNB', 'NBSVM', 'RAE'};
order = [2 1 3];
best_parameters_results = deltas_results;

fig = figure;
fig.Color = 'w';
fig.Position = [ 776 254 910 710];
i = 1;
all_deltas = [];
for k=1:4
    r = (k-1)*20 + (1:20);    
    x = (k-1)*20 + (1:5:20);
    x = test_results.trainingSetSize(x);
    ix = sorti(x, 'asc');
    x = x(ix);
    m = table2array(test_results(r, 3:end));
    ms = zeros(numel(m)/2, 2);
    ms(1:20,:) = m(:,1:2);
    ms(21:40,:) = m(:,3:4);
    ms(41:60,:) = m(:,5:6);    
    ms = ms(:,2) - ms(:,1);
    all_deltas = [all_deltas; ms];
    y_max = max(ms(:))*110;
    y_min = min(-2.5, min(ms(:)) - 0.1*abs( min(ms(:)) ));
    for li = 1:numel(classifiers)
        subplot(4,3,i+li-1)  
        ll = order(li);
        c = (ll-1)*2 + [3 4];
        y = table2array(test_results(r,c));        
        y = y(:,2) - y(:,1);
        y = reshape(y, numel(y)/4, 4)*100;
        y = y(:,ix);
        plot([0 10], [0 0], 'LineStyle', '-', 'Color', 'black');
        hold on;
        boxplot(y, 'PlotStyle','compact');
        ax = gca;
        ax.XLim = [0.5 4.5];
        ax.YLim = [y_min y_max];
        ax.XTickLabel = x;
        ax.XTick = 1:4;
        
        xlabel('T');
        ylabel('\Delta Acc. (%)');
               
        %refline(ax, [0 0]);
        if k == 1
            title(classifiers{li});
        end
    end
    i = i + 3;
end

annotation(fig,'textbox',...
    [0.02 0.808333333333333 0.0634171779141104 0.0791666666666669],...
    'String',{'CR'},...
    'FontWeight','bold',...
    'FitBoxToText','off', ...
    'EdgeColor','none');

annotation(fig,'textbox',...
    [0.02 0.594847775175644 0.0669280120695042 0.065393867446444],...
    'String','MPQA',...
    'FontWeight','bold',...
    'FitBoxToText','off',...
    'EdgeColor','none');

annotation(fig,'textbox',...
    [0.02 0.370023419203747 0.0422846917063394 0.0653938674464442],...
    'String','Rt10k',...
    'FontWeight','bold',...
    'FitBoxToText','off',...
    'EdgeColor','none');

annotation(fig,'textbox',...
    [0.02 0.156908665105386 0.0422846917063393 0.0653938674464442],...
    'String','Subj.',...
    'FontWeight','bold',...
    'FitBoxToText','off',...
    'EdgeColor','none');

export_fig(fullfile(plot_dir, 'results-box-plot'), '-pdf');