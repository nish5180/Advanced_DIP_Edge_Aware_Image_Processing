
function out = bilateral(in, sigma_t, sigma_s)
    % input image dims
    [nx, ny] = size(in);

    % Define the size of the window (neighborhood) based on sigma_s
    half_size = ceil(3 * sigma_s);  % window size proportional to spatial sigma
    
    % Precompute the spatial Gaussian kernel (spatialWeight)
    [X, Y] = meshgrid(-half_size:half_size, -half_size:half_size);
    spatialWeight = exp(-(X.^2 + Y.^2) / (2 * sigma_s^2));

    % Output image initialization
    out = zeros(nx, ny);
    
    % Loop through each pixel in the image
    for i = 1:nx
        for j = 1:ny
            % Define the region of interest (neighborhood) around pixel (i, j)
            i_min = max(i - half_size, 1);
            i_max = min(i + half_size, nx);
            j_min = max(j - half_size, 1);
            j_max = min(j + half_size, ny);
            
            % Extract the local region
            region = in(i_min:i_max, j_min:j_max);
            
            % Crop spatialWeight matrix to match region size
            spatialRegion = spatialWeight((i_min - (i - half_size) + 1):(i_max - (i - half_size) + 1), ...
                                          (j_min - (j - half_size) + 1):(j_max - (j - half_size) + 1));

            % Compute the tonal (range) weight for each pixel in the neighborhood
            center_intensity = in(i, j);
            tonalWeight = exp(-((region - center_intensity).^2) / (2 * sigma_t^2));

            % Combine spatial and tonal weights
            combinedWeight = spatialRegion .* tonalWeight;

            % Normalize the combined weights
            norm_factor = sum(combinedWeight(:));

            % Compute the filtered pixel value (weighted sum)
            out(i, j) = sum(sum(combinedWeight .* region)) / norm_factor;
        end
    end
end
