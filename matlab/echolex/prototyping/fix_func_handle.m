for i=1:numel(r.Steps)
    s = r.Steps{i};
    if isstruct(s)
        f = fieldnames(s.Args);
        
        for j=1:numel(f)
            if isa(s.Args.(f{j}), 'function_handle')
                s.Args.(f{j}) = func2str( s.Args.(f{j}) );
            end
        end
        r.Steps{i} = s;
    end
end