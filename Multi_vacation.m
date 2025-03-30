%AQM + Vacation Queueing Function
function [result] = Multi_vacation(model)
Lambda = model.Lambda; % Arrival rate
theta = model.theta; % Inverse of average vacation time
mu = model.mu; % Service rate
gamma = model.gamma; % AQM occurrence rate
Packet_Sum = model.Packet_Sum; % Number of simulated packets
system_time = 0; % System time
alpha = model.alpha;
beta = model.beta;

% Packet information: packet number, arrival time to queue, next packet arrival time, service time, whether served, whether discarded, departure time

% Create Empty Queue Structure
%empty_queue.num = []; % Packet number
empty_queue.state = []; % Queue state when packet enters (1 for active mode, 0 for vacation)
empty_queue.arrival_now = []; % Current packet arrival time
empty_queue.arrival_next = []; % Next packet arrival time
empty_queue.service_time = []; % Time when the packet is served
empty_queue.service_period = []; % Service duration for the packet
empty_queue.service_flag = [0]; % Service flag: 1 if served; 0 if not served; 2 if discarded
empty_queue.departure_time = []; % Packet departure time
empty_queue.mode_state = [1]; % State when entering queue

% Initialization
packet_pr = model.pr; % Set packet pointer to the first packet

vacation_num = zeros(Packet_Sum,1);

% Create packet information array
queue_packet = repmat(empty_queue, Packet_Sum, 1);
% Initialize each packet's arrival time and service time
arrival_period_all = [0 exprnd(1/Lambda,1,Packet_Sum-1)]; % Interarrival times
arrival_time_all = cumsum(arrival_period_all); % Arrival times
% Service times
arrival_service_period = exprnd(1/mu,1,Packet_Sum);

for i = 1:Packet_Sum
    queue_packet(i).arrival_now = arrival_time_all(i);
    queue_packet(i).service_period = arrival_service_period(i);
    if i > 1
        queue_packet(i-1).arrival_next = queue_packet(i).arrival_now;
    else
        queue_packet(i).arrival_next = queue_packet(i+1).arrival_now;
    end
end

% Initialize server state to active; the first packet is served immediately after the previous packet leaves
queue_packet(packet_pr).state = 1;
queue_packet(packet_pr).service_time = queue_packet(packet_pr).arrival_now;
system_time = queue_packet(packet_pr).arrival_now + queue_packet(packet_pr).service_period; % First packet: arrival time plus service duration
%packet_pr = packet_pr + 1;
% Queue simulation loop
queue_packet(packet_pr).service_flag = 1;
queue_packet(packet_pr).departure_time = system_time;
vacation_flag = 0; % Flag to determine switching from vacation to active mode
sum_vacation_period = 0;
while (packet_pr < Packet_Sum) % The reference time is the system time when the current packet departs
    % Active mode: if current system time is greater than or equal to the next packet arrival time (active),
    % and it is not a case of returning from vacation mode
    if (system_time >= queue_packet(packet_pr).arrival_next) & vacation_flag == 0
        packet_pr = packet_pr + 1;
        %system_time = queue_packet(packet_pr).arrival_now + queue_packet(packet_pr).service_period;
        % Update packet array
        queue_packet(packet_pr).state = 1; % Active mode arrival
        queue_packet(packet_pr).service_time = queue_packet(packet_pr-1).departure_time; % Service time set to previous packet's departure time
        queue_packet(packet_pr).service_flag = 1;
        queue_packet(packet_pr).departure_time = system_time + queue_packet(packet_pr).service_period;
        system_time = queue_packet(packet_pr).departure_time;
    elseif vacation_flag == 1 && (system_time >= queue_packet(packet_pr).arrival_now) && (queue_packet(packet_pr).service_flag == 0)
        % Active mode: the first packet served when switching from vacation to active mode.
        % At this moment, there must be packets in the queue that haven't been discarded.
        vacation_flag = 0;
        queue_packet(packet_pr).state = 1; % Active mode arrival
        queue_packet(packet_pr).service_time = system_time; % Service time equals the vacation end time
        queue_packet(packet_pr).service_flag = 1;
        queue_packet(packet_pr).departure_time = system_time + queue_packet(packet_pr).service_period;
        system_time = queue_packet(packet_pr).departure_time;
    else
        % Vacation mode: if current system time is less than the next packet arrival time (vacation),
        % even if all packets are discarded, it will return to this state
        empty_queue_vacation = queue_packet(packet_pr).arrival_next - system_time; % Duration of vacation when no packet is present
        packet_pr = packet_pr + 1; % Move pointer to the first packet arriving during vacation
        system_time = system_time + empty_queue_vacation; % Update system time to the arrival time of the first packet
        nonempty_queue_vacation = exprnd(1/theta,1,1); % Memoryless, remaining vacation time
        vacation_end_time = queue_packet(packet_pr).arrival_now + nonempty_queue_vacation; % Vacation end time (if not all packets are discarded)
        % Accumulate this vacation period
%       sum_vacation_period = sum_vacation_period + nonempty_queue_vacation + empty_queue_vacation;
        Num_packet_arrival_vacation = intersect(find([queue_packet.arrival_now]' >= system_time), find([queue_packet.arrival_now]' < system_time + nonempty_queue_vacation)); % Find indices of packets arriving during vacation
		
		amount_packet_vacation = size(Num_packet_arrival_vacation,1);
		for j = 1:amount_packet_vacation % Assign flag to packets arriving during vacation
			queue_packet(Num_packet_arrival_vacation(j)).mode_state = 0;
		end
		% AQM mechanism
		% Determine the times when AQM occurs
		arrival_AQM_temp = exprnd(1/gamma,1,Packet_Sum-1); % Interarrival times for AQM events
		arrival_AQM_time_temp = cumsum(arrival_AQM_temp) + system_time; % AQM event times
		arrival_AQM_all = find(arrival_AQM_time_temp < system_time + nonempty_queue_vacation);
		num_AQM = size(arrival_AQM_all,2); % Number of AQM events during vacation
        % If no AQM event occurs
        if num_AQM == 0
            system_time = system_time + nonempty_queue_vacation; % System time jumps to vacation end time
			vacation_flag = 1;
        end
		AQM_k = 1;
        discard_pr = 1; % Discard pointer for packets; points to the first packet eligible for discard.
                     % When a packet is discarded, move pointer to the next non-discarded packet.
		while (AQM_k <= num_AQM && amount_packet_vacation > 0 && discard_pr <= amount_packet_vacation)
            % First, determine how many packets arriving during vacation are waiting at the current AQM event
            can_discard_packet_num = 0;
            for j = discard_pr:amount_packet_vacation
                if queue_packet(Num_packet_arrival_vacation(j)).arrival_now <= arrival_AQM_time_temp(AQM_k)
                    can_discard_packet_num = can_discard_packet_num + 1;
                end
            end
			AQM_try_num = min(geornd(beta), can_discard_packet_num); % For the kth AQM event, the number of packets to discard (before stopping) follows a geometric distribution and cannot exceed the number of waiting packets
			if (AQM_try_num == 0) & (AQM_k < num_AQM) % No packet discarded and AQM event is not finished
				system_time = arrival_AQM_time_temp(AQM_k);
				AQM_k = AQM_k + 1;	
            elseif (AQM_try_num == 0) & (AQM_k < num_AQM) % No packet discarded and AQM event finished; switch to active mode
                system_time = vacation_end_time;
				AQM_k = AQM_k + 1;
			elseif (AQM_try_num < can_discard_packet_num) % This means for the current AQM event, discard AQM_try_num packets
				for k2 = 1:AQM_try_num
					queue_packet(packet_pr).state = 0; % Arrived during vacation
					queue_packet(packet_pr).service_time = NaN; % Service time does not exist
                    queue_packet(packet_pr).service_period = NaN; % Service period does not exist
					queue_packet(packet_pr).service_flag = 2;
					queue_packet(packet_pr).departure_time = arrival_AQM_time_temp(AQM_k);
					packet_pr = packet_pr + 1;
                    discard_pr = discard_pr + 1; % After discarding one packet, move the discard pointer
                end
                if AQM_k < num_AQM
                    system_time = arrival_AQM_time_temp(AQM_k);
                else
                    system_time = vacation_end_time; % If all AQM events are processed but not all packets are discarded, set system time to vacation end time
                end
				AQM_k = AQM_k + 1;
			else % All packets are discarded; at most discard can_discard_packet_num packets
                % If the queue is emptied during vacation but more packets are scheduled to arrive
                if amount_packet_vacation > (discard_pr - 1 + AQM_try_num)
                    for k2 = 1:can_discard_packet_num % Start discarding eligible packets
                        queue_packet(packet_pr).state = 0; % Arrived during vacation
                        queue_packet(packet_pr).service_time = NaN; % Service time does not exist
                        queue_packet(packet_pr).service_period = NaN; % Service period does not exist
                        queue_packet(packet_pr).service_flag = 2;
                        queue_packet(packet_pr).departure_time = arrival_AQM_time_temp(AQM_k);          
                        packet_pr = packet_pr + 1;
                        discard_pr = discard_pr + 1; % After discarding one packet, move the discard pointer
                    end
					system_time = queue_packet(packet_pr).arrival_now; % After discarding all packets, jump to the next packet arrival time
                else  % Already discarded packets + current AQM discard equals total packets arriving during vacation
                    for k2 = 1:can_discard_packet_num % Start discarding eligible packets
                        queue_packet(packet_pr).state = 0; % Arrived during vacation
                        queue_packet(packet_pr).service_time = NaN; % Service time does not exist
                        queue_packet(packet_pr).service_period = NaN; % Service period does not exist
                        queue_packet(packet_pr).service_flag = 2;
                        queue_packet(packet_pr).departure_time = arrival_AQM_time_temp(AQM_k);
                        system_time = arrival_AQM_time_temp(AQM_k); % After discarding all packets, jump to the next packet arrival time
                        packet_pr = packet_pr + 1;
                        discard_pr = discard_pr + 1; % After discarding one packet, move the discard pointer
                    end
                    packet_pr = packet_pr - 1;
                end
%				amount_packet_vacation = 0; % All packets in the queue discarded
				AQM_k = AQM_k + 1; % Cannot end AQM immediately! There might be subsequent events
			end
			vacation_flag = 1;
		end
    end
%     if packet_pr > 1
%         if (isempty(queue_packet(packet_pr-1).departure_time)) % Exception check
%             fprintf('An exception occurred here!\n\n\n');
%         end
%     end
end

%% Calculate average packet delay
system_delay = zeros(1, round(model.Packet_Sum/2));
k_delay = 0;
k_vacation = 0;
for i = round(model.Packet_Sum/2):Packet_Sum
    if (~isempty(queue_packet(i).departure_time))
        system_delay(1,i) = queue_packet(i).departure_time - queue_packet(i).arrival_now;
        k_delay = k_delay + 1;
    else
        if i < (Packet_Sum - 1)
            system_delay(1,i) = queue_packet(i+1).departure_time - queue_packet(i).arrival_now;
        end
    end
    if queue_packet(i).mode_state == 0
        k_vacation = k_vacation + 1;
    end
end
result.system_delay = sum(system_delay,2) / k_delay;
result.pw = 1 - k_vacation / round(model.Packet_Sum/2);
result.ps = 1 - result.pw;
result.system_length = result.system_delay * model.Lambda;

% pw_test = 1 - (sum_vacation_period / (queue_packet(Packet_Sum-1).departure_time));

PAoI_average_sim = mean(arrival_period_all(2:end)) + result.system_delay;
result.paoi = PAoI_average_sim;

fprintf('Simulation (with AQM): Arrival rate %f, average system delay %f, probability of active state %f, average queue length %f, average peak age of information %f\n\n\n', model.Lambda, result.system_delay, result.pw, result.system_length, PAoI_average_sim);
