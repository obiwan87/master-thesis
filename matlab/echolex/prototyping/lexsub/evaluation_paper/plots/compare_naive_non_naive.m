% compare naive and non-naive

% Group all different parameter combinations by dataset
[G1, params_datasets_t] = findgroups(all_results(:,1:7));

% Calculate mean accuracy for each parameter combination per dataset
mean_acc_groups = splitapply(@mean, all_results.mean_acc_sub_n_svm, G1);

% Separate naive / non-naive approahces
l = (params_datasets_t.b == 1 & params_datasets_t.a == 0) | params_datasets_t.b == 0;
l1 = (params_datasets_t.b == 1 & params_datasets_t.a == 0);
l2 = params_datasets_t.b == 0;

naive_params_datasets_mean_acc1 = [params_datasets_t(l1,:) table(mean_acc_groups(l1), 'VariableNames', {'acc'})];
naive_params_datasets_mean_acc2 = [params_datasets_t(l2,:) table(mean_acc_groups(l2), 'VariableNames', {'acc'})];
non_naive_params_datasets_mean_acc = [params_datasets_t(~l,:) table(mean_acc_groups(~l), 'VariableNames', {'acc'})];

% Calculate best parameter combination of naive approaches
[G21, params_naive_datasets_t1] = findgroups(naive_params_datasets_mean_acc1(:,1:2));
best_of_params_naive_datasets_acc1 = splitapply(@max, naive_params_datasets_mean_acc1.acc, G21);

[G22, params_naive_datasets_t2] = findgroups(naive_params_datasets_mean_acc2(:,1:2));
best_of_params_naive_datasets_acc2 = splitapply(@max, naive_params_datasets_mean_acc2.acc, G22);

% Calculate best parameter combination among non-naive approaches
[G3, params_non_naive_datasets_t] = findgroups(non_naive_params_datasets_mean_acc(:,1:2));
best_of_params_non_naive_datasets_acc = splitapply(@max, non_naive_params_datasets_mean_acc.acc, G3);

best_non_naive_params = [params_non_naive_datasets_t table(best_of_params_non_naive_datasets_acc, 'VariableNames', {'acc'})]
best_naive_params1 = [params_naive_datasets_t1 table(best_of_params_naive_datasets_acc1, 'VariableNames', {'acc'})]
best_naive_params2 = [params_naive_datasets_t2 table(best_of_params_naive_datasets_acc2, 'VariableNames', {'acc'})]