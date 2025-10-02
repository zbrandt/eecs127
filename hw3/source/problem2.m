A = [ 1  1  1;
     -1  1  0;
     -1 -1  1;
      1  0  1;
     -1  1  1;
      0 -1  1 ];

x_star = [ 1; 
           1; 
           1 ];

% store errors
err_l1 = zeros(41, 41);
err_l2 = zeros(41, 41);

t = -2.0:0.1:2.0;
for i = 1:length(t)
    disp(i)
    for j = 1:length(t)
        disp(j)
        
        t1 = t(i);
        t2 = t(j);

        v = [ t1;
              0; 
              0; 
              0; 
              t2; 
              0 ];
        b = A*x_star + v;
        
        cvx_begin quiet
            variable x1(3)
            minimize( norm(A * x1 - b, 1) )
        cvx_end
        err_l1(i, j) = norm(x1 - x_star, 2);

        cvx_begin quiet
            variable x2(3)
            minimize( norm(A * x2 - b, 2) )
        cvx_end
        err_l2(i, j) = norm(x2 - x_star, 2);
    end
end    

[T1, T2] = meshgrid(t, t);

% compare error matrices
err = err_l1 < err_l2;

figure('Name','Problem 2','NumberTitle','off');

% plot full, red circles on points where err_l1 < err_l2
plot(T1(err), T2(err), 'ro', 'MarkerSize', 4, 'MarkerFaceColor','r');

% plot full, blue circles on points where err_l2 <= err_l1
plot(T1(~err), T2(~err), 'bo', 'MarkerSize', 4, 'MarkerFaceColor','b');

hold on;
grid on;
xlabel('t_1');
ylabel('t_2');
title('Estimator errors l1, l2');
axis equal;



