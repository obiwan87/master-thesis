function pname = shortclass(o)
pname = strsplit(class(o), '.');
pname = pname{end};
end