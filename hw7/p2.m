experiments = 10;
vertices = zeros(experiments, 1);

for i = 1:experiments
    % Generate random A and b with elements in [-1, 1]
    A = 2*rand(5, 40) - 1;
    b = 2*rand(5, 1) - 1;
   
    count = 0;
    
    % Get combinations for all possible indices
    combinations = nchoosek(1:40, 5);
    
    for j = 1:size(combinations, 1);
        % Select arbitrary indices and get columns
        indices = combinations(j, :);
        A_basis = A(:, indices);
        
        % Check if columns are linearly independent
        if rank(A_basis) == 5
            % Find unique vector y
            y = A_basis \ b;
            
            % Check if y >= 0
            if all(y >= 0)  
                count = count + 1;
            end
        end
    end
    
    disp(count)
    vertices(i) = count;
end

% Calculate expected number of vertices
expected_vertices = mean(vertices);
disp(expected_vertices)