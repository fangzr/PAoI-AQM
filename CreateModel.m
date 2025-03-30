% Function to initialize experimental parameters
function model = CreateModel()
model.Lambda = 8; % Arrival rate
model.theta = 0.1; % Inverse of average vacation time
model.mu = 10; % Service rate
model.gamma = 4; % AQM occurrence rate
model.pr = 1; % Packet pointer
model.alpha = 0.2; % AQM packet discard probability
model.beta = 1 - model.alpha; % AQM packet retention probability

% Packet_Sum = input('Please input the max sum of packets (No more than 1e6)');

Packet_Sum = 5000;

if isempty(Packet_Sum)
    Packet_Sum = 1e6;
end;

model.Packet_Sum = Packet_Sum;
