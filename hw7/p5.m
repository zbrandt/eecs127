% Compressed Sensing Experiment with CVX
% This script tests the minimum number of measurements needed to recover
% a sparse signal using L1 minimization

clear; clc; close all;

%% Define the true sparse vector x*
n = 1000;  % dimension
x_star = zeros(n, 1);
x_star(10) = 5;
x_star(20) = -2;
x_star(95) = 7;
x_star(750) = 15;
x_star(920) = -10;

fprintf('True sparse vector x* has %d nonzero entries\n', nnz(x_star));
fprintf('L1 norm of x*: %.2f\n\n', norm(x_star, 1));

%% Experiment parameters
m_values = 5:100;  % range of measurement numbers
num_trials = 10;   % number of experiments per m
threshold = 0.01;  % success threshold

% Store success probabilities
p_m = zeros(length(m_values), 1);

%% Run experiments
fprintf('Running experiments...\n');
for idx = 1:length(m_values)
    m = m_values(idx);
    success_count = 0;
    
    for trial = 1:num_trials
        % Generate random measurement vectors (Gaussian i.i.d.)
        A = randn(m, n);
        
        % Compute measurements y = A * x*
        y = A * x_star;
        
        % Solve L1 minimization problem using CVX
        cvx_begin quiet
            variable x_hat(n)
            minimize(norm(x_hat, 1))
            subject to
                A * x_hat == y
        cvx_end
        
        % Check if successful (error < 0.01)
        error = norm(x_star - x_hat, 1);
        if error < threshold
            success_count = success_count + 1;
        end
    end
    
    % Compute empirical success probability
    p_m(idx) = success_count / num_trials;
    
    % Progress update
    if mod(idx, 10) == 0
        fprintf('Progress: m = %d, p(m) = %.2f\n', m, p_m(idx));
    end
end

fprintf('\nExperiments completed!\n\n');

%% Plot the results
figure('Position', [100, 100, 800, 600]);
plot(m_values, p_m, 'b-o', 'LineWidth', 2, 'MarkerSize', 6, 'MarkerFaceColor', 'b');
grid on;
xlabel('Number of measurements (m)', 'FontSize', 12);
ylabel('Empirical success probability p(m)', 'FontSize', 12);
title('Compressed Sensing: Success Probability vs. Number of Measurements', 'FontSize', 14);
ylim([-0.05, 1.05]);
xlim([min(m_values), max(m_values)]);

% Add horizontal line at p = 0.5
hold on;
plot([min(m_values), max(m_values)], [0.5, 0.5], 'r--', 'LineWidth', 1.5);
legend('p(m)', 'p(m) = 0.5', 'Location', 'southeast');

%% Find phase transition point
% Find the smallest m where p(m) >= 0.9 (high success rate)
high_success_idx = find(p_m >= 0.9, 1, 'first');
if ~isempty(high_success_idx)
    m_transition = m_values(high_success_idx);
    fprintf('Phase transition (p >= 0.9) occurs at m = %d\n', m_transition);
    fprintf('This is %.1f times the sparsity level (k = 5)\n', m_transition / 5);
end

% Find where p(m) crosses 0.5
mid_success_idx = find(p_m >= 0.5, 1, 'first');
if ~isempty(mid_success_idx)
    m_half = m_values(mid_success_idx);
    fprintf('p(m) >= 0.5 first occurs at m = %d\n\n', m_half);
end

%% Display key observations
fprintf('=== KEY OBSERVATIONS ===\n');
fprintf('1. Sparsity level: k = 5 (number of nonzero entries)\n');
fprintf('2. Signal dimension: n = 1000\n');
fprintf('3. Phase transition behavior observed:\n');
fprintf('   - For small m: p(m) ≈ 0 (recovery fails)\n');
fprintf('   - Transition region: p(m) increases rapidly\n');
fprintf('   - For large m: p(m) ≈ 1 (recovery succeeds)\n');
fprintf('4. Recovery possible with m << n (compressed sensing works!)\n');
fprintf('5. Typically need m ≈ O(k log(n/k)) measurements\n');
fprintf('   For this problem: k log(n/k) ≈ 5 * log(200) ≈ 26.5\n\n');

%% Summary statistics
fprintf('=== SUMMARY STATISTICS ===\n');
fprintf('Range where 0 < p(m) < 1:\n');
transition_range = m_values(p_m > 0 & p_m < 1);
if ~isempty(transition_range)
    fprintf('  m ∈ [%d, %d]\n', min(transition_range), max(transition_range));
end
fprintf('Minimum m for perfect success (p=1): ');
perfect_idx = find(p_m == 1, 1, 'first');
if ~isempty(perfect_idx)
    fprintf('%d\n', m_values(perfect_idx));
else
    fprintf('Not achieved in tested range\n');
end