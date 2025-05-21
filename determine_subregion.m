function [R, center] = determine_subregion(I, level, x0, y0)
%GET_SUBREGION Extracts a patch R from full-res image I centered on pixel (x0, y0) at pyramid level
%   I      : full-resolution image (grayscale or RGB)
%   level  : pyramid level (1-indexed)
%   x0, y0 : coordinates in the Gaussian pyramid at 'level'
%   R      : output subregion from I
%   center : [row, col] index of full-res pixel (x_f, y_f) within R

    % Scale factor between pyramid level and full-resolution
    scale = 2^(level - 1);
    
    % Full-resolution pixel corresponding to (x0, y0) at level 'level'
    x_f = (x0 - 1) * scale + 1;
    y_f = (y0 - 1) * scale + 1;

    % Approximate half-width of the region based on 5-tap Gaussian filter support
    h = 3 * scale - 2;  

    % Image size
    [rows, cols, ~] = size(I);

    % Range of the patch (clipped to image boundaries)
    xmin = max(1, x_f - h);
    xmax = min(cols, x_f + h);
    ymin = max(1, y_f - h);
    ymax = min(rows, y_f + h);

    % Extract subregion from full-resolution image
    R = I(ymin:ymax, xmin:xmax, :);

    % Return the center index inside the subregion (used for coefficient lookup)
    center = [y_f - ymin + 1, x_f - xmin + 1];
end
