function pyr = create_gaussian_pyramid(I, nlev)

    pyr = cell(nlev, 1);       % initializing to 0
    disp(pyr);
    pyr{1} = I;                % Level 1 is original image
    
    
    f = [0.05, 0.25, 0.4, 0.25, 0.05]; %https://visionbook.mit.edu/pyramids_new_notation.html, 
    % convolving the image with a low pass filter, coefficients adding up to 1 to ensure normalization

    gauss_filter = f' * f;     % Outer product → 2D kernel, creating a matrix to form the kernel, we want a 2d gaussian kernel

    for l = 2:nlev
        % Apply filter to each channel
        I_blurred = zeros(size(I), 'like', I);
        for ch = 1:size(I, 3)
            I_blurred(:, :, ch) = imfilter(I(:, :, ch), gauss_filter, 'symmetric'); %filters the image with the gaussian filter 
        end
        
        % Downsample (reduce size by half)
        I = I_blurred(1:2:end, 1:2:end, :);
        
        % Store in pyramid
        pyr{l} = I;
    end
end






