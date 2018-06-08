[bootstrap_script_path, ~, ~] = fileparts([mfilename('fullpath') '.m']);
cd(bootstrap_script_path);

addpath(genpath('../matlab'));

cd('../../data');
echolex_data = pwd;

cd('../dumps/');
echolex_dumps = pwd;

cd('../results/');
echolex_results = pwd;

%bigram_substitution_test_8
