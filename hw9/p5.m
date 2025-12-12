n = 1000;
rng(42); % For reproducibility

% Coefficients are all randomly generated via a uniform distribution on
% the interval [0, 1]
a = rand(n, 1);
b = rand(n, 1);

f = @(x) sum(x.^4) + (sum(a.*x))^2 + sum(b.*x); % objective
grad_f = @(x) 4*x.^3 + 2*(sum(a.*x))*a + b; % gradient of objective
hess_f = @(x) diag(12*x.^2) + 2*(a*a'); % Hessian of objective

% Write code in CVX to find a global minimum x*
cvx_begin quiet
    variable x_cvx(n)
    minimize(sum(pow_pos(x_cvx, 4)) + pow_pos(sum(a.*x_cvx), 2) + sum(b.*x_cvx))
cvx_end

fprintf('CVX optimal value = %.10f\n', f(x_cvx));
fprintf('CVX gradient norm = %.10e\n\n', norm(grad_f(x_cvx)));

% Constant step size
fprintf('Constant step size\n');

% Select different values for s and run Newton's algorithm
step_sizes = [0.001, 0.01, 0.05, 0.1, 0.5, 1.0];
max_iter = 10000;
tol = 1e-4; % 0.0001

for s_idx = 1:length(step_sizes)
    s = step_sizes(s_idx);
    fprintf('s = %.3f:\n', s);
    
    x = ones(n, 1);
    found = false;
    for k = 0:max_iter-1
        g = grad_f(x);
        grad_norm = norm(g);
        
        if grad_norm < tol
            fprintf('Found point at iteration %d\n', k);
            fprintf('Gradient norm = %.6e\n', grad_norm);
            fprintf('Distance to x* = %.6e\n\n', norm(x - x_cvx));
            found = true;
            break;
        end
        
        % Run Newton's algorithm
        H = hess_f(x);
        delta_x = H \ g;
        x = x - s * delta_x;
    end
    
    if ~found && k == max_iter-1
        fprintf('Did not find a point within 10000 iterations\n');
        fprintf('Final gradient norm = %.6e\n\n', k, grad_norm);
    end
end

% Adaptive stepsize scheme "backtracking"
fprintf('Adaptive stepsize scheme "backtracking"\n');

s_init = 5;
alpha = 0.4;
tol = 1e-4;
max_iter = 10000;

x = ones(n, 1);
x_history = zeros(n, max_iter+1);
x_history(:, 1) = x;
error_history = zeros(max_iter+1, 1);
error_history(1) = norm(x - x_cvx);

for k = 0:max_iter-1
    g = grad_f(x);
    grad_norm = norm(g);
    
    if grad_norm < tol
        fprintf('Found point at iteration τ = %d\n', k);
        fprintf('Final gradient norm = %.6e\n', grad_norm);
        fprintf('Distance to x* = %.6e\n', norm(x - x_cvx));
        fprintf('Function value = %.10f\n', f(x));
        fprintf('Optimal value = %.10f\n\n', f(x_cvx));
        tau = k;
        break;
    end
    
    H = hess_f(x);
    delta_x = H \ g;
    
    % Find the right m
    f_current = f(x);
    m = 0;
    while true
        s_k = s_init * alpha^m;
        x_new = x - s_k * delta_x;
        
        if f(x_new) < f_current
            break;
        end
        m = m + 1;
        
        if m > 100
            error('Too many iterations with m');
        end
    end
    
    x = x_new;
    x_history(:, k+2) = x;
    error_history(k+2) = norm(x - x_cvx);
    
    fprintf('i = %4d, norm = %.4e, dist = %.4e, m_k = %d\n', k, grad_norm, error_history(k+1), m);
end

% Trim history
x_history = x_history(:, 1:tau+1);
error_history = error_history(1:tau+1);

% Plot the distance norm using a linear scale on the x-axis and a base-10
% logarithmic scale on the y-axis
figure('Position', [100, 100, 800, 600]);
semilogy(0:tau, error_history, 'b-', 'LineWidth', 2);
grid on;
xlabel('Iteration k', 'FontSize', 12);
ylabel('base-10 log of ||x^{(k)} - x*||', 'FontSize', 12);
title('Newton''s algorithm with backtracking', 'FontSize', 14);
set(gca, 'FontSize', 11);