c = [5; -7; 10; 3; -1];
A = [-1 -3  3 -1 -2;
      2 -5  3 -2 -2];
b = [0; 3];

cvx_begin
    variable x(5)
    maximize( c' * x )
    subject to
        A * x <= b;
        -x(2) + x(3) + x(4) - x(5) >= 2;
        0 <= x <= 3;
cvx_end

fprintf('Optimal x = [%g %g %g %g %g]\n', x);
fprintf('Optimal objective = %g\n', c' * x);
