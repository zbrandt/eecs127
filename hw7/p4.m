% CVX script for the transportation LP (MATLAB + CVX)
% Data
s = [40; 30; 20];      % supplies for warehouses 1..3 (3 is fictitious)
d = [30; 30; 30];      % demands for customers 1..3
C = [20 25 20; 10 30 40; 90 80 70];  % cost matrix (3x3)

m = 3; n = 3;

cvx_begin
    variables X(m,n)
    minimize( sum(sum(C .* X)) )
    subject to
        % supply limits
        for i=1:m
            sum(X(i,:)) <= s(i);
        end
        % demand equalities
        for j=1:n
            sum(X(:,j)) == d(j);
        end
        X >= 0;
cvx_end

disp('Optimal shipment matrix X (rows warehouses, cols customers):')
disp(X)
disp(['Total cost: $', num2str(cvx_optval)])
