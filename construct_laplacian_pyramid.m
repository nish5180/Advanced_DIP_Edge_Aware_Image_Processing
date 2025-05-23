function pyr = construct_laplacian_pyramid(I, nlev)
% Builds a Laplacian pyramid with nlev levels from input image I

    % Step 1: Create Gaussian pyramid
    G = create_gaussian_pyramid(I, nlev);

    % Step 2: allocate Laplacian pyramid
    pyr = cell(nlev, 1);

    % Step 3: Compute Laplacian levels, this is only for grayscale inputs,
    % for color we will need to loop over different channels 
    for l = 1:nlev-1
        % Upsample G_{l+1} to match G_{l} so we can subtract
        upsampled = imresize(G{l+1}, size(G{l}), 'nearest');

        % Subtract to get Laplacian level
        pyr{l} = G{l} - upsampled;
    end

    % Step 4: Final level is just the residual (coarsest Gaussian)
    pyr{nlev} = G{nlev};
end
