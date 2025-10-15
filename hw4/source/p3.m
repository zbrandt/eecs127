close all;
images = {'Berkeley1.png', 'Berkeley2.png'};
for i = 1:length(images)
    image = imread(images{i});

    % 1. Convert the image to grayscale
    A = im2double(rgb2gray(image));
    [m, n] = size(A);
    
    % 2. Plot the singular values of A
    [U, S, V] = svd(A);
    singular_values = diag(S);
    figure;
    plot(1:length(singular_values), singular_values, 'b-');
    xlabel('k');
    ylabel('\sigma_k');
    title(['Singular values of ', images{i}]);
    grid on;
    
    % 3. Solve low-rank optimization problem
    ks = [30, 80, 100];
    figure;
    for j = 1:length(ks)
        k = ks(j);
        Bk = U(:,1:k) * S(1:k,1:k) * V(:,1:k)';
        error = norm(A - Bk, 'fro')^2 / norm(A, 'fro')^2;
        percentage = k / min(m,n) * 100;
        subplot(1, length(ks), j);
        imshow(Bk);
        title(sprintf('k = %d (%.2f%%)', k, percentage));
    end
end
