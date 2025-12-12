s = [40; 30; 20];
d = [30; 30; 30];
C = [20 25 20; 
     10 30 40; 
     90 80 70];

cvx_begin
    variables X(3,3)
    minimize( sum(sum(C .* X)) )
    subject to
        % Set supply constraint
        for i=1:3
            sum(X(i,:)) <= s(i);
        end
        % Set demand constraint
        for j=1:3
            sum(X(:,j)) == d(j);
        end
        X >= 0;
cvx_end

disp(X)
disp(num2str(cvx_optval))
