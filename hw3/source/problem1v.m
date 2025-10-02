A = [ 2  0  0;
     -1  1  0;
     -1 -1  1];
B = [-1; -1; 1];

x0 = [0;0;0];
x_d = [3; 2; 2];

H = [A^3 * B, A^2 * B, A * B, B];

cvx_begin quiet
    variable u(4)
    minimize( sum_square(u) ) % sum squares of elements of u
    subject to
        x_d - H * u == 0
cvx_end

% display inputs and energy
disp('Optimal sequence of inputs u(0), ..., u(3) = ');
disp(u(:));
fprintf('Total energy = %g\n', sum(u.^2));

X = zeros(3,5);                         % store x(0), ..., x(4) to columns of X
X(:,1) = x0;                            % store zeros in first column for x(0) 
for k = 1:4 
    X(:,k+1) = A * X(:,k) + B * u(k);   % fill in the rest of X iteratively
end

% check x_d == x(4)
fprintf('x(4) = [%.6g  %.6g  %.6g]^T\n', X(:,5));


figure('Name','Problem 1 (v)','NumberTitle','off');

% connect each point with '-o'
plot3(X(1,1:5), X(2,1:5), X(3,1:5), '-o','LineWidth',1.5,'MarkerSize',8,'MarkerFaceColor','auto');

hold on;
grid on;
xlabel('x_1');
ylabel('x_2');
zlabel('x_3');
title('Optimal trajectory x(0), ..., x(4)');
axis equal;

% annotate points x(0), ..., x(4)
for k = 0:4
    txt = sprintf('x(%d)', k);
    text(X(1,k+1)+0.1, X(2,k+1)+0.1, X(3,k+1)+0.1, txt);
end