for i=1:numel(R1.Sessions)
    session = R1.Sessions{i};
    report = session.Report;
    
    c = cell(size(report));
    for j=1:size(report,1)
        for k=1:numel(report(j,:))
            s = report{j,k};
            if ~isempty(s)
                argNames = s.Args(1:2:end);
                argValues = s.Args(2:2:end);
                argValues = cellfun(@(x) str(x), argValues, 'UniformOutput', false);
                
                args = {argNames{:}; argValues{:}};
                args = arrayfun(@(x) sprintf('%s: %s', args{1,x}, args{2,x}), 1:size(args,2), 'UniformOutput', false);
                args = strjoin(args, ', ');
                
                c{j,k} = sprintf('%s=[%s]', s.Name, args);
                
                if strfind(s.Name, 'Classifier')
                    c{j,k} = sprintf('%s{loss: %.2f %%}',c{j,k}, s.Out.loss*100);
                end
            else
                c{j,k} = '*';
            end
        end
    end
end