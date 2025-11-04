N = 200;
solutions = zeros(N, 2);

for i = 1:N
    alpha = 2 * rand - 1;
    beta  = 2 * rand - 1;

    cvx_begin quiet
        variables x1 x2
        minimize(alpha * x1 + beta * x2)
        subject to
            x1 >= 0
            x2 >= 0
            x1 + 4 * x2 <= 4
            4 * x1 + x2 <= 4
    cvx_end

    solutions(i, :) = [x1, x2];
end

disp(solutions)

counts = dictionary(string.empty(0,1), zeros(0,1));
for i = 1:N
    x = mat2str(round(solutions(i, :), 3));
    if ~isKey(counts, x)
        counts(x) = 0;
    end
    counts(x) = counts(x) + (1 / N);
end

disp(counts);