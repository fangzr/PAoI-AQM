clear all
close all
% WCL simulation for multiple vacation M/M/1 with/without AQM
addpath test;
rng('default'); % for reproducibility

% Parameter initialization
model = CreateModel();

% Set the unified base path for saving simulation results
basePath = 'E:\your-path\Simulation\';

%% Experiment 1 simulation results output
[model.theta, model.mu, model.gamma, model.alpha, model.beta] = deal(3, 10, 4, 0.6, 0.4); % Variable assignment
[result_paoi_sim, result_paoi_close, ab_error, relative_error] = Lab_test_1(model);
filename = fullfile(basePath, 'A_lambda_1.mat');
save(filename);

%% Experiment 2 simulation results output
[model.theta, model.mu, model.alpha, model.beta, model.gamma] = deal(6, 10, 0.5, 0.5, 4); % Variable assignment
[result_paoi_sim, result_paoi_close, ab_error, relative_error] = Lab_test_1(model);
filename = fullfile(basePath, 'A_lambda_2.mat');
save(filename);

%% Experiment 3 simulation results output (regarding theta)
[model.Lambda, model.mu, model.gamma, model.alpha, model.beta] = deal(5, 10, 4, 0.4, 0.6); % Variable assignment
[result_paoi_sim, result_paoi_close] = Lab_test_theta(model);
filename = fullfile(basePath, 'A_theta.mat');
save(filename);

%% Experiment 4 simulation results output
[model.theta, model.mu, model.Lambda, model.alpha, model.beta] = deal(3, 10, 5, 0.5, 0.5); % Variable assignment
[result_paoi_sim, result_paoi_close, ab_error, relative_error] = Lab_test_gamma(model);
filename = fullfile(basePath, 'A_gamma_1.mat');
save(filename);

%% Experiment 5 simulation results output
[model.theta, model.mu, model.Lambda, model.gamma] = deal(3, 10, 6, 4); % Variable assignment
[result_paoi_sim, result_paoi_close, ab_error, relative_error] = Lab_test_alpha(model);
filename = fullfile(basePath, 'A_alpha_1.mat');
save(filename);

%% Experiment 6 simulation results output
[model.theta, model.mu, model.alpha, model.beta, model.gamma] = deal(0.1, 10, 0.2, 0.8, 4); % Variable assignment
[result_paoi_sim, result_paoi_close, ab_error, relative_error] = Lab_test_1(model);
filename = fullfile(basePath, 'A_lambda_3.mat');
save(filename);

%% Experiment 7 simulation results output
[model.theta, model.mu, model.alpha, model.beta, model.gamma] = deal(1, 10, 0.2, 0.8, 4); % Variable assignment
[result_paoi_sim, result_paoi_close, ab_error, relative_error] = Lab_test_1(model);
filename = fullfile(basePath, 'A_lambda_4.mat');
save(filename);

%% Experiment 9 simulation results output
[model.theta, model.mu, model.gamma, model.alpha, model.beta] = deal(10, 10, 5, 0.2, 0.8); % Variable assignment
[result_paoi_sim, result_paoi_close, ab_error, relative_error] = Lab_test_1(model);
filename = fullfile(basePath, 'A_lambda_5.mat');
save(filename);
save(filename);

%% Experiment 10 simulation results output
[model.theta, model.mu, model.Lambda, model.gamma] = deal(1, 10, 5, 5); % Variable assignment
[result_paoi_sim, result_paoi_close, ab_error, relative_error] = Lab_test_alpha(model);
filename = fullfile(basePath, 'A_alpha_2.mat');
save(filename);

%% Non-AQM simulation section
% (Non-AQM experiment code commented out)

% Plot and display results, boxplot + closed-form solution line chart
f = msgbox('Operation Completed!', 'Done');
load gong
sound(y, Fs);
