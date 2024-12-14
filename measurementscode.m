% Main function to analyze entropy when random measurements are introduced
function analyze_entropy_with_measurements(num_qubits, num_layers)
    % Define probabilities from 0 to 1 with step size 0.1
    probabilities = 0:0.1:1;
    entropies_per_p = zeros(1, length(probabilities));  % Store average entropy for each p
    m = ceil(num_qubits / 2);
    max_entropy_half_chain = m - 1/(2*log(2));  % Maximum possible entropy

    for idx = 1:length(probabilities)
        p = probabilities(idx);  % Current probability
        entropy_half_chain = 0;  % Reset entropy for each probability
        for layer = 1:num_layers
            t = create_random_circuit_with_measurements(num_qubits, num_layers, p);  % Modified function to apply measurements
            datadir = runsingleprogram('entropycircuit', 1);

            [qstate,rdata] = loadstatefromfile([datadir '/qstate,t=' num2str(t) '.bin']);
                  
            % Calculate entropy after applying measurements
            entropy_half_chain = calcentropy(qstate, 1:ceil(num_qubits / 2)).entropy;
        end
        % Store the entropy for the current probability
        entropies_per_p(idx) = entropy_half_chain;
    end

    % Plot entropy vs measurement probability
    figure;
    plot(probabilities, entropies_per_p, 'bo-', 'LineWidth', 2);
    hold on;
    yline(max_entropy_half_chain, 'r--', 'LineWidth', 2);  % Max entropy threshold
    xlabel('Measurement Probability (p)');
    ylabel('Renyi Entropy (S^{(2)}_A / log(2))');
    title('Renyi Entropy vs Measurement Probability');
    legend('Renyi Entropy', 'Max Entropy Threshold');
    grid on;
end

% Function to create a random quantum circuit with measurements
function t = create_random_circuit_with_measurements(num_qubits, num_layers, p)
    t = 0;  % Initialize timestep counter
    fileID = fopen('programs\entropycircuit.chp','w');
    fprintf(fileID, '#\n');

    % Loop through layers and apply gates and measurements
    for layer = 1:num_layers
        % Apply single-qubit gates (H, X, Z)
        for qubit = 1:num_qubits
            gate = randi([1 3]);  % Randomly choose between H, X, Z gates
            switch gate
                case 1
                    fprintf(fileID, 'h %d\n', qubit-1);  % Apply H gate
                    t = t + 1;
                case 2
                    fprintf(fileID, 'h %d\n', qubit-1);  % Apply X gate
                    t = t + 1;
                case 3
                    fprintf(fileID, 'p %d\n', qubit-1);  % Apply P gate
                    t = t + 1;
            end
        end

        % Apply two-qubit entangling gates (CNOT)
        num_entangling_gates = ceil(num_qubits / 2);
        for i = 1:num_entangling_gates
            control = randi([0 num_qubits-1]);  % Random control qubit
            % Choose target from the remaining qubits, ensuring it's not the same as control
            possible_targets = setdiff(0:num_qubits-1, control);  % Exclude control from possible targets
            target = possible_targets(randi(length(possible_targets)));  % Random target qubit
            fprintf(fileID, 'c %d %d\n', control, target);  % Apply CNOT gate
            t = t + 1;
        end

        % Apply measurements with probability p
        for qubit = 1:num_qubits
            if rand() < p
                fprintf(fileID, 'm %d\n', qubit-1);  % Measure qubit
                t = t + 1;
            end
        end
    end

    fclose(fileID);
end


% Provided entropy function
function entrobj = calcentropy(qstate, region, stabdestab)
    % qstate includes stabilizers AND destabilizers
    if nargin < 3
        stabdestab = 'stab';
    end

    Nsites = length(qstate) / 2;

    % Remove any trailing NaNs
    region = region(1:find(~isnan(region), 1, 'last'));

    if isempty(region)
        entrobj.entropy = 0;
        entrobj.region = [];
        return;
    end

    if strcmp(stabdestab, 'stab')  % Use stabilizers
        statex = qstate(Nsites+1:end, 1:Nsites);
        statez = qstate(Nsites+1:end, Nsites+1:end);
    else  % Use destabilizers
        statex = qstate(1:Nsites, 1:Nsites);
        statez = qstate(1:Nsites, Nsites+1:end);
    end

    statesubreg = [statex(:, region+1) statez(:, region+1)];  % Add 1 to every index (CHP is indexed from 0, matlab is indexed from 1)

    S = gfrank(statesubreg, 2) - length(region);

    entrobj.entropy = S;
    entrobj.region = region;
end


num_qubits = 10;
num_layers = 25;
analyze_entropy_with_measurements(num_qubits, num_layers);


%idea if we wanted to count the measurements: 

% num_measurements = 0;
%   entropy_reached_zero = false;

    % File handling for additional measurements
    % Open the file again for subsequent measurements
%    fileID = fopen('programs/entropycircuit.chp', 'a');

%    while ~entropy_reached_zero
        % Apply random measurements with probability p
%        for qubit = 1:num_qubits
%           x = rand();
%            if x < p
 %               fprintf(fileID, 'm %d\n', qubit-1);  % Perform measurement
  %          end
   %     end

        % Recalculate the entropy after measurements
%        entropy_half_chain = calcentropy(qstate, 1:ceil(num_qubits / 2)).entropy;

        % Check if entropy has reached zero
%        if entropy_half_chain <= 0.01  % Threshold for near-zero entropy
%            entropy_reached_zero = true;
%        else
%            num_measurements = num_measurements + 1;  % Increment number of measurements
%        end

        % Avoid infinite loops by breaking after too many measurements
%        if num_measurements > 1000
%            warning('Max number of measurements reached without reaching zero entropy.');
%            break;
%        end
%    end
