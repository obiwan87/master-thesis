% Retrieve home dir of data
global echolex_data echolex_src echolex_dumps business_signals_data 

echolex_data = getandcheckenvpath('ECHOLEX_DATA');
echolex_src = getandcheckenvpath('ECHOLEX_SRC');
echolex_dumps = fullfile(echolex_src, '../dumps');
business_signals_data = fullfile(echolex_data, 'business_signals_samples');
business_signals = dir(business_signals_data);
business_signals = business_signals(~[business_signals.isdir]);
business_signals = unique(cellfun(@(x) first(strsplit(x,'.')), {business_signals.name}, 'UniformOutput', false));

javaaddpath(fullfile(echolex_src, '/lib/jar/mongo-java-driver.jar'))
store = ExperimentReportsStore('10.67.50.34', 'master-thesis', 'experiments');
if exist('gpuDevice', 'builtin')
    g = gpuDevice;
end

% Python path
insert(py.sys.path, int32(0), fullfile(echolex_src, 'python'));

% If no display available, edit files with 'vim'
setenv('EDITOR', 'vim');

