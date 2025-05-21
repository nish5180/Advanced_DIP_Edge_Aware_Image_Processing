function R = lapfilter_core(I, r_func, nlev)
% Core Local Laplacian Filtering algorithm (simplified and modular)
% I      : full-resolution grayscale image (double, [0,1])
% r_func : remapping function handle @(patch, guide) → remapped patch
% nlev   : number of pyramid levels

% Step 1: Gaussian pyramid of input
G = create_gaussian_pyramid(I, nlev);

% Step 2: Prepare empty Laplacian output pyramid
L_out = cell(nlev, 1);
for l = 1:nlev
    L_out{l} = zeros(size(G{l}));
end

% Step 3: Loop through all coefficients
for l = 1:nlev-1
    [rows, cols] = size(G{l});

    for y = 1:rows
        for x = 1:cols
            % 3.1 Get guide value from Gaussian pyramid at level l
            g = G{l}(y, x);

            % 3.2 Get subregion and center index from full-res image
            [R, center] = determine_subregion(I, l, x, y);

            % 3.3 Apply remapping to the subregion
            R_remapped = r_func(R, g);  % remapping_function handles the detail/edge logic

            % 3.4 Build Laplacian pyramid of the remapped patch
            L_patch = construct_laplacian_pyramid(R_remapped, l);

            % 3.5 Extract single coefficient safely
            if l <= length(L_patch)
                [ph, pw] = size(L_patch{l});
                cy = center(1);
                cx = center(2);

                if cy <= ph && cx <= pw
                    L_out{l}(y, x) = L_patch{l}(cy, cx);
                end
            end
        end
    end
end

% Step 4: Copy last Gaussian level as residual
L_out{nlev} = G{nlev};

% Step 5: Reconstruct final image
R = collapse_laplacian_pyramid(L_out);
R = min(max(R, 0), 1);  % Clamp to [0, 1]

end


% Set parameters
gray_img = im2double(rgb2gray(imread('peppers.png')));
nlev = 5;
s = 0.01;
alpha = 0.3;
beta = 0.3;

% Define remapping function handle
r_func = @(patch, g) remapping_function(patch, g, s, alpha, beta);

% Run the Laplacian core (returns the pyramid)
R = lapfilter_core(gray_img, r_func, nlev);

figure;

subplot(1, 2, 1);
imshow(gray_img);
title('Input Grayscale Image');

subplot(1, 2, 2);
imshow(R);
title('Filtered Output Image');