function find_layers_for_max_entropy(num_qubits)
    % Set up to track entropy per layer
    max_entropy_reached = false;
    num_layers = 1;  % Start with one layer
    entropies_half_chain = [];
    m = ceil(num_qubits / 2);

    % max_possible_entropy = (num_qubits - log(num_qubits));  % Correct Page curve for Renyi entropy
    % if the half chain is maximum usually the rest is also maximum 
    max_possible_entropy =  m - 1/(2*log(2));

    % Page curve value for comparison (the maximum theoretical entropy)
    page_curve = max_possible_entropy;

    % Set a maximum number of layers to avoid infinite loops
    max_layers_limit = 100;  % Limit to prevent infinite loops

    % Tolerance for considering entropy as "maximum"
    tolerance = 0.01;  % Small tolerance to determine when we're close to max entropy

    % Initialize array to store entropy values for each layer
    entropy_per_layer = [];

    % Continue adding layers until maximum entropy is reached or max layers reached
    while ~max_entropy_reached && num_layers <= max_layers_limit
        % Generate random quantum circuit with the current number of layers
        t = create_random_circuit(num_qubits, num_layers); 
        
        datadir = runsingleprogram('entropycircuit',1);
        
        [qstate,rdata] = loadstatefromfile([datadir '/qstate,t=' num2str(t) '.bin']);
        entropies_by_size = zeros(num_qubits, 1);
        binom = zeros(num_qubits, 1);

        % Calculate binomial coefficients (N choose k)
        for i = 1:num_qubits
            binom(i) = nchoosek(num_qubits, i);
        end

       
        % Calculate average entropy for this layer and store it
        entropy_half_chain = calcentropy(qstate, 1:ceil(num_qubits / 2)).entropy;

        entropies_half_chain = [entropies_half_chain, entropy_half_chain];
        % Define the max entropy for the half-chain region (ceil(num_qubits / 2))
       
        %max_entropy_half_chain = (m - 0.5 * log(m));  % Adjust Page curve for half-chain
        max_entropy_half_chain =  m - 1/(2*log(2));

        % Check if the Renyi entropy has reached the Page curve (maximum entropy)
        if  entropy_half_chain > page_curve
            max_entropy_reached = true;
            fprintf('Max entropy reached with %d layers.\n', num_layers);
        else
            num_layers = num_layers + 1;  % Increase the number of layers and try again
        end
    end


    %as soon as the systems reaches the max value 
    % If max_layers_limit is reached without achieving max entropy
    if ~max_entropy_reached
        disp('Reached max number of layers without achieving maximum entropy.');
    end

  
    
    % Plot Renyi entropy vs layers with a threshold for half-chain max entropy
    figure;
    plot(1:length(entropies_half_chain), entropies_half_chain, 'r-d', 'LineWidth', 2);  % Renyi entropy for half-chain
  % Renyi entropy for half-chain
    hold on;
    yline(max_entropy_half_chain, 'k--', 'LineWidth', 2);  % Max entropy threshold
    xlabel('Number of Layers');
    ylabel('Renyi Entropy (S^{(2)}_A / log(2))');
    title('Renyi Entropy vs Circuit Layers');
    legend('Renyi Entropy', 'Max Entropy Threshold');
    grid on;
end

% Function to create a random quantum circuit with more focus on entangling gates
function t = create_random_circuit(num_qubits, num_layers)
    t = 0;
    
    fileID = fopen('programs\entropycircuit.chp','w');
    fprintf(fileID,'#\n');

    % Generate random layers of quantum gates
    for layer = 1:num_layers
        % Apply random single-qubit gates for each qubit
        for qubit = 1:num_qubits
            gate = randi([1 3]);  % Randomly choose between H, X, Z gates
            switch gate
                case 1
                    fprintf(fileID,'h %d\n',qubit-1);  % Apply H gate
                case 2
                    fprintf(fileID,'h %d\n',qubit-1);  % Apply H gate
                    t = t+1;
                case 3
                    fprintf(fileID,'p %d\n',qubit-1);  % Apply P gate
                    t = t+1;
                    % measurement 
            end
        end
% put the measurements here and track the entropy 
% measure the half chain entropy and choose 100 random subregions 
% plot 

        % Apply random two-qubit entangling gates (focus on entangling operations)
        num_entangling_gates = ceil(num_qubits / 2);  % Apply entangling gates

        for i = 1:num_entangling_gates
            control = randi([1 num_qubits]) - 1;  % Random control qubit
            target = randi([1 num_qubits]) - 1;   % Random target qubit
            while control == target
                target = randi([1 num_qubits]) - 1;  % Ensure different qubits
            end
            fprintf(fileID,'c %d %d\n',control,target);  % Apply CNOT gate
            t = t+1;
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


% Run the function with 10 qubits
num_qubits = 10;
find_layers_for_max_entropy(num_qubits);

% change the number of qbits
% plot numqbits on xaxis and number of layers on yaxis
% half chain entanglement should predict the other subregions 
%check if a given random subregion has maximum entropy 