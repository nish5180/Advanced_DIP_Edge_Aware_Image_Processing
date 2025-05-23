%% Step 1: Create white background with black square
img = ones(64, 64);             % white image
img(24:40, 24:40) = 0;          % black square in the center

figure;
imshow(img);
title('White Background with Black Square');

%% Step 2: Build Gaussian pyramid
nlev = 4;
G = create_gaussian_pyramid(img, nlev);

%% Step 3: Compute Laplacian at level 2
l = 1;
G_up = imresize(G{l+1}, size(G{l}), 'bilinear');
L = G{l} - G_up;  % Laplacian level 2

figure;

subplot(2,2,1);
imshow(img);
title('Original (White + Black Square)');

subplot(2,2,2);
imshow(mat2gray(G{l+1}));
title(sprintf('Gaussian Level %d', l));

subplot(2,2,3);
imshow(mat2gray(G_up));
title(sprintf('Upsampled G_{%d} ', l+1));

subplot(2,2,4);
imshow(mat2gray(L));
title(sprintf('Laplacian Level %d', l));

%% Step 5: Print example Laplacian values
% Inside white area
fprintf('White region L(5,5) = %.4f\n', L(5,5));

% Inside black square
fprintf('Black region L(20,20) = %.4f\n', L(20,20));

% At edge (adjust if needed to align with edge after downsampling)
fprintf('Edge region L(12,12) = %.4f\n', L(12,12));



%% Step 1: Create white background with black square

% img = im2double(rgb2gray(imread('peppers.png')));
gray_img = im2single(imread('C:\Users\nishi\Documents\TUDelft\Quarter_4\Image_Processing\input_images\input_png\stripes.png'));

figure;
imshow(gray_img);
title('White Background with Black Square');


B = locallapfilt(gray_img, 0.01, 0.5, 5);
imshow(B);

title('White Background with Black Square locallapfilt');



%%
patch = ones(10,10);
g = 1;
s = 1;
alpha = 1;
beta = 1;

remapped = remapping_function(patch, g, s, alpha, beta);
disp(remapped);  % Should all be 1s

%%
img = ones(64, 64);     % uniform white image
nlev = 5;
L = construct_laplacian_pyramid(img, nlev);
R = collapse_laplacian_pyramid(L);

disp(max(abs(R(:) - img(:))));  % should be near zero
imshow(R);

