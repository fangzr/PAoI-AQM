% Closed-form solution with AQM
function result = Close_Form_AQM(model)
Lambda = model.Lambda; % Arrival rate
theta = model.theta; % Inverse of average vacation time
mu = model.mu; % Service rate
gamma = model.gamma; % AQM occurrence rate
Packet_Sum = model.Packet_Sum; % Number of simulated packets
system_time = 0; % System time
alpha = model.alpha;
beta = model.beta;
rho = Lambda / mu;

%% Compute z1 and z2
B_temp = -1 * gamma * beta + theta + Lambda + gamma + alpha * Lambda;
deta = (B_temp)^2 - 4 * alpha * Lambda * (theta + Lambda + gamma);

z1 = (B_temp - sqrt(deta)) / (2 * Lambda);
z2 = (B_temp + sqrt(deta)) / (2 * Lambda);

%% Compute pi_00
temp_pi_0 = beta * (z2 - 1) * (mu - Lambda);
temp_pi_1 = z2 * (beta * (mu - Lambda) + Lambda * (1 - z1));
Pi_00 = temp_pi_0 / temp_pi_1;

%% Compute p_w and p_s
temp_pw_0 = Pi_00 * z2 * rho * (1 - z1);
temp_pw_1 = beta * (z2 - 1) * (1 - rho);
p_w = temp_pw_0 / temp_pw_1;
p_s = z2 * Pi_00 / (z2 - 1);

%% Compute average system delay
temp1 = z2 * Pi_00 / (1 - z2)^2;
temp2_0 = rho * (1 - z1) * z2 * Pi_00 * (z2 - rho);
temp2_1 = beta * (z2 - rho * z2 - 1 + rho)^2;
system_delay = (temp1 + temp2_0 / temp2_1) / Lambda;
system_delay_2 = (beta * (1 - rho) * (1 + (rho * (1 - z1) * (z2 - rho) / (beta * (1 - rho)^2))) / ((z2 - 1) * (beta * (1 - rho) + rho * (1 - z1)))) / Lambda;
paoi_2 = 1 / Lambda + system_delay_2;

%% Compute average queue length
system_length = system_delay * Lambda;

%% Compute average peak age of information (PAoI)
PAoI_average = 1 / Lambda + system_delay;
fprintf('Closed-form solution: Average system delay %f, probability of active state %f, average queue length %f, peak age of information %f (alternate expression: %f)\n\n\n', system_delay, p_w, system_length, PAoI_average, paoi_2);
result = PAoI_average;
