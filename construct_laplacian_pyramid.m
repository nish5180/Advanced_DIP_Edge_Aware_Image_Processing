function pyr = construct_laplacian_pyramid(I, nlev)
    G = create_gaussian_pyramid(I, nlev);
    pyr = cell(nlev, 1);
    filter = pyramid_filter();

    for l = 1:nlev-1
        upsampled = upsample_and_filter(G{l+1}, filter, size(G{l}));
        pyr{l} = G{l} - upsampled;
    end

    pyr{nlev} = G{nlev};  % Residual
end


% function up = upsample_and_filter(img, filt, target_size)
%     % 1. Upsample by inserting zeros
%     upsampled = zeros(2*size(img));
%     upsampled(1:2:end, 1:2:end) = img;
% 
%     % 2. Apply separable filter
%     filt = filt(:);
%     up = conv2(filt, filt', upsampled, 'same');
%     up = up(1:target_size(1), 1:target_size(2));
% 
% 
%     % 3. Resize to match target pyramid level
% 
% end

function up = upsample_and_filter(img, filt, target_size)
    % 1. Upsample by inserting zeros
    upsampled = zeros(2*size(img));
    upsampled(1:2:end, 1:2:end) = img;

    % 2. Apply separable filter and apply factor of 4
    filt = filt(:);
    up = conv2(filt, filt', upsampled, 'same') * 4; % *** CRITICAL CORRECTION: Add * 4 ***

    % 3. Crop to target size (should already be correctly handled by 'same' convolution, but good for safety)
    % Ensure output size matches target_size, as conv2 with 'same' might not perfectly match 2x original + boundary issues
    up = up(1:target_size(1), 1:target_size(2)); % Keep this line, as it ensures exact target size


    
end


function f = pyramid_filter()
    % Standard 5-tap Gaussian kernel used in Burt & Adelson (sum = 16)
    f = [1 4 6 4 1] / 16;
end



































% function pyr = construct_laplacian_pyramid(I, nlev)
% % Builds a Laplacian pyramid with nlev levels from input image I
% 
%     % Step 1: Create Gaussian pyramid
%     G = create_gaussian_pyramid(I, nlev);
% 
%     % Step 2: allocate Laplacian pyramid
%     pyr = cell(nlev, 1);
% 
%     % Step 3: Compute Laplacian levels, this is only for grayscale inputs,
%     % for color we will need to loop over different channels 
%     for l = 1:nlev-1
%         % Upsample G_{l+1} to match G_{l} so we can subtract
%         upsampled = imresize(G{l+1}, size(G{l}), 'bilinear');
% 
%         % Subtract to get Laplacian level
%         pyr{l} = G{l} - upsampled;
%     end
% 
%     % Step 4: Final level is just the residual (coarsest Gaussian)
%     pyr{nlev} = G{nlev};
% end
