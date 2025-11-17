experiments = 10;
num_vertices = zeros(experiments,1);

for i = 1:experiments
    
    # Generate a random pair
    A = 2*rand(5,40) - 1;
    b = 2*rand(5,1) - 1;

    combos = nchoosek(1:40,5);
    count = 0;

    for j = 1:size(combos,1)
        idx = combos(j,:);
        M = [A(:,idx) eye(5)];
        rhs = b;

        sol = M\rhs;
        xB = sol(1:5);
        if all(xB >= 0)
            count = count + 1;
        end
    end

    num_vertices(i) = count;
end

expected_vertices = mean(vertex_counts);
disp(expected_vertices)
