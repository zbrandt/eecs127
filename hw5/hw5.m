% Solve the optimization problem
cvx_begin quiet
    variables x(3) y(3)
    minimize( norm(x - y) )
    subject to
        x(1)^2 + x(2)^2 + x(3)^2 <= 3;
        x(1) + x(2) + x(3) >= 0.5;
        y(1)^2 + y(2)^2 + y(3)^2 <= 30;
        y(1) + y(2) + y(3) >= 9;
cvx_end

% Show optimal distance, x, and y
fprintf('Optimal distance: %f\n', norm(x - y));
fprintf('x* = [%f, %f, %f]\n', x(1), x(2), x(3));
fprintf('y* = [%f, %f, %f]\n', y(1), y(2), y(3));

% Show that the intersection of S1 and S2 is empty
if norm(x - y) > 0
    fprintf('S1 and S2 are disjoint (no intersection).\n');
else
    fprintf('S1 and S2 intersect.\n');
end

% Obtain a separating hyperplane
a = x - y;              
b = a' * ((x + y) / 2);     % a^T (x - m) = 0 => a^T x = a^T m = b  

% Show a, b
fprintf('a = [%f, %f, %f]\n', a(1), a(2), a(3));
fprintf('b = %f\n', b);