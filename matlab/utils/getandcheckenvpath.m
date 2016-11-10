function [ val, s ] = getandcheckenvpath(name)

s = true;
val = getenv(name);

if isempty(val) 
    warning('Environment variable ''%s'' is not set', name);
    s = false;
elseif ~exist(val, 'dir')
    warning('''%s'' is pointing to a non-existent path', name);
    s = false;
end

end

