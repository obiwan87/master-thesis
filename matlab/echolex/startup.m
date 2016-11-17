% Retrieve home dir of data
global echolex_data echolex_src echolex_dumps business_signals_data 

echolex_data = getandcheckenvpath('ECHOLEX_DATA');
echolex_src = getandcheckenvpath('ECHOLEX_SRC');
echolex_dumps = fullfile(echolex_src, '../../../dumps');
business_signals_data = fullfile(echolex_data, 'business_signals_samples');


% If no display available, edit files with 'vim'
setenv('EDITOR', 'vim');