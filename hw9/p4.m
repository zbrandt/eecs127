n = 200;                    
num_trials = 40;           
count = 0;         

for trial = 1:num_trials
    fprintf('Trial %d/%d\n', trial, num_trials);
    
    % Generate a vector y with n = 200, where each entry is selected from
    % a normal distribution.
    y = randn(n, 1);
    
    % Generate a vector z, where each entry is selected from a uniform 
    % distribution on the interval [0,1]
    z = rand(n, 1);
    
    % Calculate the matrix X* = yz^T
    X_star = y * z';
    
    % Randomly select m = 0.1*n^2 elements of this set and denote the 
    % obtained subset with K
    all_indices = randperm(n^2, 0.1 * n^2);
    [rows, cols] = ind2sub([n, n], all_indices);
    K = [rows', cols'];
    
    % Measure the entries X*_ij for all (i,j) in K, leading to measuring
    % 10% entries of X*
    observed_values = zeros(0.1 * n^2, 1);
    for idx = 1:(0.1 * n^2)
        i = K(idx, 1);
        j = K(idx, 2);
        observed_values(idx) = X_star(i, j);
    end
    
    % Form a nuclear-norm optimization problem to find X*, let the
    % obtained solution be denoted by X_hat 
    cvx_begin quiet
        variable X_hat(n, n)
        minimize(norm_nuc(X_hat))
        subject to
            for idx = 1:(0.1 * n^2)
                i = K(idx, 1);
                j = K(idx, 2);
                X_hat(i, j) == observed_values(idx);
            end
    cvx_end
    
    % Declare the success of the optimization problem in finding X*
    error = norm(X_hat - X_star, 2);
    
    if error <= 0.01
        count = count + 1;
        fprintf('Success\n');
    else
        fprintf('Failure, error = %.6f\n', error);
    end
end

% Find the empirical probability of the success of the nuclear norm
% minimization
probability = count / num_trials;

fprintf('Probability: %.2f%% (%.3f)\n', probability*100, probability);