n = 100;  % number of nodes
trials = 100;  % run the following experiment 100 times
lambda = 1/100;
count = 0;

edges = [(1:n-1)', (2:n)'; n, 1]; % 100 x 2 matrix of edges
num_edges = size(edges, 1); % should be 100

% Define attack locations
attacked_nodes = [5, 15, 25, 35, 45, 55, 65, 75, 85, 95];
attacked_lines_idx = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100];

for trial = 1:trials
    % generate the line reactances
    Z = zeros(n, n);
    for e = 1:num_edges
        i = edges(e, 1);
        j = edges(e, 2);
        Z_ij = 0.1 + (0.2 - 0.1) * rand();
        Z(i, j) = Z_ij;
        Z(j, i) = Z_ij; % for symmetry in matrix
    end
    
    % generate the nodal phases
    theta_star = -pi/18 + (pi/18 - (-pi/18)) * rand(n, 1);
    
    % calculate flow
    P_ij = zeros(n, n);
    for e = 1:num_edges
        i = edges(e, 1);
        j = edges(e, 2);
        P_ij(i, j) = (theta_star(i) - theta_star(j)) / Z(i, j);
        P_ij(j, i) = -P_ij(i, j);
    end
    
    % calculate for node over each row of matrix
    P_i = sum(P_ij, 2);
    
    % generate each measurement for every node
    w_i = 0.001 * randn(n, 1);
    v_i_star = zeros(n, 1);
    for node = attacked_nodes
        v_i_star(node) = -10 + 20 * rand();
    end
    P_i_hat = P_i + w_i + v_i_star;
    
    % generate each measurement for every line
    P_ij_meas = zeros(num_edges, 1);
    w_ij = 0.001 * randn(num_edges, 1);
    v_ij_star = zeros(num_edges, 1);
    
    for e = 1:num_edges
        i = edges(e, 1);
        j = edges(e, 2);
        P_ij_meas(e) = P_ij(i, j) + w_ij(e);
        
        % if line is under attack
        if ismember(e, attacked_lines_idx)
            v_ij_star(e) = -10 + 20 * rand();
            P_ij_meas(e) = P_ij_meas(e) + v_ij_star(e);
        end
    end
    
    % solve lasso using CVX
    cvx_begin quiet
        variables theta(n) omega_i(n) omega_ij(num_edges) v_i(n) v_ij(num_edges)
        
        minimize( sum(omega_i.^2) + sum(omega_ij.^2) + lambda * (sum(abs(v_i)) + sum(abs(v_ij))) )
        
        subject to
            theta(1) == 0;
            
            % nodal measurement constraints
            for i = 1:n
                % find neighbors of node i
                neighbors = [];
                for e = 1:num_edges
                    if edges(e, 1) == i
                        neighbors = [neighbors, edges(e, 2)];
                    elseif edges(e, 2) == i
                        neighbors = [neighbors, edges(e, 1)];
                    end
                end
                
                % sum of flows = injection
                flow_sum = 0;
                for j = neighbors
                    flow_sum = flow_sum + (theta(i) - theta(j)) / Z(i, j);
                end
                
                P_i_hat(i) == flow_sum + omega_i(i) + v_i(i);
            end
            
            % line measurement constraints
            for e = 1:num_edges
                i = edges(e, 1);
                j = edges(e, 2);
                P_ij_meas(e) == (theta(i) - theta(j)) / Z(i, j) + omega_ij(e) + v_ij(e);
            end
    cvx_end
    
    % check if lasso correctly identified all attack locations
    threshold = 0.01;
    
    % check nodal attacks
    nodal_correct = true;
    for i = 1:n
        is_attacked = ismember(i, attacked_nodes);
        if is_attacked
            if abs(v_i(i)) <= threshold
                nodal_correct = false;
                break;
            end
        else
            if abs(v_i(i)) > threshold
                nodal_correct = false;
                break;
            end
        end
    end
    
    % check line attacks
    line_correct = true;
    for e = 1:num_edges
        is_attacked = ismember(e, attacked_lines_idx);
        if is_attacked
            if abs(v_ij(e)) <= threshold
                line_correct = false;
                break;
            end
        else
            if abs(v_ij(e)) > threshold
                line_correct = false;
                break;
            end
        end
    end
    
    % both conditions must hold
    if nodal_correct && line_correct
        count = count + 1;
    end
end

% report final results
rate = 100 * count / trials;
fprintf('count: %d\n', count);
fprintf('rate: %.2f%%\n', rate);