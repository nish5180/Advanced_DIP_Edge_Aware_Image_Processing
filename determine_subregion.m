function [R, center] = determine_subregion(I, level, x0, y0)
% Extracts a subregion R from full-res image I centered on the location
% corresponding to (x0, y0) at pyramid level `level`.
% Returns the patch R and the center index at the target level.

    % Scale factor between pyramid level and full-resolution
    scale = 2^(level - 1);
    
    % Full-resolution pixel corresponding to (x0, y0)
    x_f = (x0 - 1) * scale + 1;
    y_f = (y0 - 1) * scale + 1;

    % Half-width of patch based on 5-tap kernel support
    % K = 3 * (2^(level + 2) - 1);
    % h = floor((K-1)/2); % symmetric half-width
     h = 3 * scale - 2;

    % Full-res image size
    [rows, cols, ~] = size(I);

    % Bounds for patch in full-resolution coordinates
    xmin = max(1, x_f - h);
    xmax = min(cols, x_f + h);
    ymin = max(1, y_f - h);
    ymax = min(rows, y_f + h);

    % Extract patch
    R = I(ymin:ymax, xmin:xmax, :);

    % Center index in full-resolution patch
    y_center_full = y_f - ymin + 1;
    x_center_full = x_f - xmin + 1;

    % Convert to current pyramid level by downsampling
    center_y = floor((y_center_full - 1) / scale) + 1;
    center_x = floor((x_center_full - 1) / scale) + 1;

    center = [center_y, center_x];  % return as (row, col)
end
