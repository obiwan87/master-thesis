[bootstrap_script_path, ~, ~] = fileparts([mfilename('fullpath') '.m'])
cd(bootstrap_script_path);

addpath(genpath('../matlab'));

cd('../../data');
echolex_data = pwd;

cd('../dumps/');
echolex_dumps = pwd;

cd('../results/');
echolex_results = pwd;

load(fullfile(echolex_data, 'training_validation.mat'));
Ws = public_datasets_training_validation;

bigram_substitution_test_8
