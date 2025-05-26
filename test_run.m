
image = imread('input_images\input_png\lenna.png'); % Choose image file
gray_img = im2single(rgb2gray(image)); % Convert to single-valued grayscale for processing

% gray_img = ones(64, 64, 'single');  % white background
% gray_img(24:40, 24:40) = 0;         % black square in the center

nlev = 5; % Num of levels

% 
s = 0.2;
alpha = 0.5;
beta = 2;

% Remapping function handle
r_func = @(patch, g) remapping_function(patch, g, s, alpha, beta);


% Run filtering
tic;
R = lapfilter_core(gray_img, r_func, nlev);
toc;

% 1. locallapfilt()
s_local = 0.2; 
alpha_local = 1.5; 
img_locallap_filtered = locallapfilt(single(gray_img), s_local, alpha_local);

% 2. tonemap
img_tonemapped_matlab = tonemap(gray_img); % Applies default tone mapping

% Display input and result
figure;
subplot(2, 3, 1); imshow(gray_img); 
title('Input Grayscale Image');
subplot(2, 3, 2); imshow(R);
title(sprintf('lapfiltercore() (s=%.1f,a=%.1f,b=%.1f)', s, alpha, beta));
subplot(2, 3, 3); imshow(mat2gray(gray_img - R));
title('Diff Output Image');
subplot(2, 3, 4);
imshow(img_locallap_filtered);
title(sprintf('MATLAB locallapfilt() (s=%.2f, a=%.2f)', s_local, alpha_local));
subplot(2, 3, 5);
imshow(img_tonemapped_matlab);
title('MATLAB tonemap()');



