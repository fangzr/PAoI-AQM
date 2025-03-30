% Closed-form solution without AQM
function result = Close_Form_NA(model)
Lambda = model.Lambda; % Arrival rate
theta = model.theta; % Inverse of average vacation time
mu = model.mu; % Service rate
gamma = model.gamma; % AQM occurrence rate
Packet_Sum = model.Packet_Sum; % Number of simulated packets
system_time = 0; % System time
alpha = model.alpha;
beta = model.beta;
rho = Lambda/mu;

%% Compute r11, r21, r22
r11 = rho;
r22 = Lambda/(theta + Lambda);
r21 = theta * r22 / (mu * (1 - r22));
R = zeros(2,2);
R(1,1) = rho;
R(1,2) = 0;
R(2,1) = r21;
R(2,2) = r22;

%% Compute pi_00
Pi_00 = (1 - r22) * (1 - rho) / (1 - rho + r21);

Pi_00_test_0 = inv(eye(2) - R) * ones(2,1);
Pi_00_test = Pi_00_test_0(2,1);

%% Compute p_w and p_s
temp_ps_0 = 1 - rho;
temp_ps_1 = 1 - rho + r21;
p_s = temp_ps_0 / temp_ps_1;
p_w = 1 - p_s;

%% Compute average system delay
Pi_0 = zeros(1,2);
Pi_0(1,1) = 0;
Pi_0(1,2) = Pi_00;
system_delay = (Pi_0 * (inv((eye(2) - R)^2) * R * ones(2,1))) / Lambda;

%% Compute average queue length
system_length = system_delay * Lambda;

%% Compute average peak age of information (PAoI)
PAoI_average = 1 / Lambda + system_delay;

fprintf('Closed-form solution: Average system delay %f, probability of active state %f, average queue length %f, peak age of information %f\n\n\n', system_delay, p_w, system_length, PAoI_average);
result = PAoI_average;
