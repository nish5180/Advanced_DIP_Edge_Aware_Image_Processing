function reconstructed_image = collapse_laplacian_pyramid(laplacian_pyramid)
%COLLAPSE_LAPLACIAN_PYRAMID Reconstructs an image from its Laplacian pyramid.
%   laplacian_pyramid: A cell array representing the Laplacian pyramid,
%                      where laplacian_pyramid{1} is the finest level
%                      and laplacian_pyramid{nlev} is the coarsest (residual).
%   reconstructed_image: The reconstructed image.

    nlev = length(laplacian_pyramid);

    % Start with the coarsest level of the Gaussian pyramid,
    % which is the residual L_n (the last level of the Laplacian pyramid)
    % G_n = L_n
    current_gaussian_level = laplacian_pyramid{nlev}; % [cite: 67]

    % Iterate from nlev-1 down to 1
    % G_l = L_l + upsample(G_{l+1})
    for l = (nlev-1):-1:1
        % Upsample the previously reconstructed Gaussian level (G_{l+1})
        % to match the size of the current Laplacian level (L_l)
        target_size = size(laplacian_pyramid{l});
        upsampled_gaussian = imresize(current_gaussian_level, [target_size(1) target_size(2)], 'bilinear'); % [cite: 66]

        % Add the current Laplacian level
        current_gaussian_level = laplacian_pyramid{l} + upsampled_gaussian; % [cite: 68]
    end

    reconstructed_image = current_gaussian_level; % This is G_0, the original image [cite: 68]

end