
function R = collapse_laplacian_pyramid(pyr)
%COLLAPSE_LAPLACIAN_PYRAMID Reconstructs an image from its Laplacian pyramid.
%   pyr: cell array {L1, L2, ..., Ln}, where Ln is the residual (coarsest level).
%   R: reconstructed full-resolution image

    nlev = length(pyr);
    filter = pyramid_filter();  % 5-tap kernel: [1 4 6 4 1]/16

    R = pyr{nlev};  % Start from coarsest level

    for lev = (nlev-1):-1:1
        % Upsample and filter to match size of current level
        up = upsample_and_filter(R, filter, size(pyr{lev}));
        % Add Laplacian coefficient
        R = up + pyr{lev};
    end
end

function up = upsample_and_filter(img, filt, target_size)
    % 1. Upsample by inserting zeros
    upsampled = zeros(2*size(img));
    upsampled(1:2:end, 1:2:end) = img;

    % 2. Apply separable filter
    filt = filt(:);
    up = conv2(filt, filt', upsampled, 'same');

    % 3. Resize to match target pyramid level
    up = imresize(up, target_size, 'bilinear');
end

function f = pyramid_filter()
    % Standard 5-tap Gaussian kernel used in Burt & Adelson (sum = 16)
    f = [1 4 6 4 1] / 16;
end












% function reconstructed_image = collapse_laplacian_pyramid(laplacian_pyramid)
% %COLLAPSE_LAPLACIAN_PYRAMID Reconstructs an image from its Laplacian pyramid.
% %   laplacian_pyramid: A cell array representing the Laplacian pyramid,
% %                      where laplacian_pyramid{1} is the finest level
% %                      and laplacian_pyramid{nlev} is the coarsest (residual).
% %   reconstructed_image: The reconstructed image.
% 
%     nlev = length(laplacian_pyramid);
% 
%     % Start with the coarsest level of the Gaussian pyramid,
%     % which is the residual L_n (the last level of the Laplacian pyramid)
%     % G_n = L_n
%     current_gaussian_level = laplacian_pyramid{nlev}; % [cite: 67]
% 
%     % Iterate from nlev-1 down to 1
%     % G_l = L_l + upsample(G_{l+1})
%     for l = (nlev-1):-1:1
%         % Upsample the previously reconstructed Gaussian level (G_{l+1})
%         % to match the size of the current Laplacian level (L_l)
%         target_size = size(laplacian_pyramid{l});
%         upsampled_gaussian = imresize(current_gaussian_level, [target_size(1) target_size(2)], 'bilinear'); % [cite: 66]
% 
%         % Add the current Laplacian level
%         current_gaussian_level = laplacian_pyramid{l} + upsampled_gaussian; % [cite: 68]
%     end
% 
%     reconstructed_image = current_gaussian_level; % This is G_0, the original image [cite: 68]
% 
% end