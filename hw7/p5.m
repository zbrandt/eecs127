n = 1000;
x = zeros(n, 1);
x(10) = 5;
x(20) = -2;
x(95) = 7;
x(750) = 15;
x(920) = -10;

disp(norm(x, 1));

m_values = 5:100;
experiments = 10;
precision = 0.01;

p_m = zeros(length(m_values), 1);

for i = 1:length(m_values)
    m = m_values(i);
    successes = 0;
    
    % Run experiment 10 times
    for trial = 1:experiments
        % Generate m rows of a columns i.i.d.
        A = randn(m, n);
        
        % Compute all measurements y = A * x*
        y = A * x;
        
        cvx_begin quiet
            variable x_hat(n)
            minimize(norm(x_hat, 1))
            subject to
                A * x_hat == y
        cvx_end
        
        error = norm(x - x_hat, 1);
        if error < precision
            successes = successes + 1;
        end
    end
    
    % Compute p(m) series
    p_m(i) = successes / experiments;
    disp(p_m)
end

figure('Position', [100, 100, 800, 600]);
plot(m_values, p_m, 'b-o', 'LineWidth', 2, 'MarkerSize', 6, 'MarkerFaceColor', 'b');
grid on;
xlabel('m', 'FontSize', 12);
ylabel('p(m)', 'FontSize', 12);
title('p(m) v.s. m', 'FontSize', 14);
ylim([-0.05, 1.05]);
xlim([min(m_values), max(m_values)]);

% Add horizontal line at p = 0.5
hold on;
plot([min(m_values), max(m_values)], [0.5, 0.5], 'r--', 'LineWidth', 1.5);
legend('p(m)', 'p(m) = 0.5', 'Location', 'southeast');